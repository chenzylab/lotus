import { Marked } from 'marked';
import { createHighlighter, type Highlighter } from 'shiki';
import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

/**
 * md → 渲染片段管线，架构思路参照 Ripple 官方文档站
 * （`~/i/ripple/website-new/src/lib/markdown.js`：import.meta.glob 预读 md 源文件 +
 * marked 解析 + shiki 高亮 + frontmatter/TOC 提取），用 lotus 自己的实现重写，不搬运代码。
 * 详见 specs/cross-cutting/docs-site.spec.md「调研依据」。
 *
 * 与官方版本的关键差异一（渲染形态）：官方把整篇文档渲染成单一 HTML 字符串用 innerHTML 注入，
 * 代码演示只是静态高亮（可交互 Playground 走的是 iframe 内嵌独立部署的 LiveCodes，不在同一
 * 渲染树里）。lotus 需要在文档正文中内嵌"真实渲染、真实可交互"的 demo 组件（而不仅是静态代码
 * 高亮），但 tsrx 组件的 import 必须是静态的、innerHTML 字符串里也无法混入真实 Ripple 组件实例
 * （未找到可行的技术方案，评估后放弃这条路径）。因此 getDoc 不返回单一 html 字符串，而是返回
 * 一个「片段数组」：普通正文片段各自独立跑 marked 渲染成小段 HTML（用 innerHTML 注入），
 * ` ```tsrx demo ` 代码块切分出独立的 demo 片段（只携带 demo 的引用信息，由页面组件侧显式
 * import 对应的 demo 组件模块渲染），两种片段按原文顺序交替排列，页面用 `@for` 遍历渲染。
 *
 * 与官方版本的关键差异二（同步性）：Ripple 组件函数体内不允许直接 `await`（tsrx-tsc 报错
 * "await is not allowed inside components. Use trackAsync(...) with an upstream
 * @try {...} @pending {...} boundary instead"）。官方 markdown.js 用**模块顶层 await**
 * 提前把 shiki highlighter 初始化好（`const highlighter = await createHighlighter(...)`），
 * 使得 `get_doc(slug)` 函数本身保持完全同步，`module server` 里可以直接同步调用、无需
 * `trackAsync`/`@try`/`@pending` 边界。本文件照抄这个模式，`getDoc` 是同步函数。
 */

const __dirname = dirname(fileURLToPath(import.meta.url));
const DOCS_ROOT = resolve(__dirname, '../../docs');

const highlighter: Highlighter = await createHighlighter({
  themes: ['github-light', 'github-dark'],
  langs: ['typescript', 'javascript', 'tsx', 'jsx', 'css', 'html', 'bash', 'json', 'markdown'],
});

function escapeHtml(text: string): string {
  return text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

export interface Frontmatter {
  title?: string;
  category?: string;
  [key: string]: string | undefined;
}

/** 解析 YAML-like frontmatter（仅支持简单 `key: value` 行，不引入完整 YAML 解析器依赖）。 */
export function parseFrontmatter(content: string): { frontmatter: Frontmatter; body: string } {
  const match = content.match(/^---\n([\s\S]*?)\n---\n/);
  if (!match) return { frontmatter: {}, body: content };

  const frontmatter: Frontmatter = {};
  for (const line of match[1]!.split('\n')) {
    const colon = line.indexOf(':');
    if (colon === -1) continue;
    const key = line.slice(0, colon).trim();
    const value = line.slice(colon + 1).trim();
    frontmatter[key] = value;
  }

  return { frontmatter, body: content.slice(match[0].length) };
}

export interface TocItem {
  href: string;
  text: string;
  level: number;
}

/** 从 body（未渲染的原始 markdown）中提取二三级标题作为 TOC。 */
export function extractToc(body: string): TocItem[] {
  const toc: TocItem[] = [];
  const headingRegex = /^(#{2,3})\s+(.+)$/gm;
  let match: RegExpExecArray | null;
  while ((match = headingRegex.exec(body)) !== null) {
    const level = match[1]!.length;
    const text = match[2]!.replace(/`([^`]*)`/g, '$1').trim();
    const id = slugify(text);
    toc.push({ href: `#${id}`, text, level });
  }
  return toc;
}

function slugify(text: string): string {
  return text
    .toLowerCase()
    .replace(/[^\w\s一-鿿-]/g, '')
    .replace(/\s+/g, '-');
}

/**
 * 处理 VitePress 风格的自定义容器块：`::: info/tip/warning/danger 标题 \n 内容 \n :::`
 */
function processContainers(content: string): string {
  return content.replace(
    /^:::\s*(info|tip|warning|danger|details)\s*(.*?)\n([\s\S]*?)\n:::[ \t]*$/gm,
    (_match, type: string, title: string, body: string) => {
      const rawTitle = title.trim();
      const titleHtml = rawTitle ? `<p class="custom-block-title">${escapeHtml(rawTitle)}</p>` : '';
      return `<div class="${type} custom-block">${titleHtml}\n\n${body.trim()}\n\n</div>`;
    },
  );
}

export interface DemoRef {
  /** md 中引用的相对路径（相对于该 md 文件所在目录）。 */
  relativePath: string;
  /** 解析后的绝对路径。 */
  absolutePath: string;
  /** demo 源码内容，供高亮展示。 */
  source: string;
  /** 供页面组件比对、生成静态 import 语句提示的模块标识（去掉 .tsrx 后缀的相对路径）。 */
  moduleId: string;
}

/**
 * 提取所有 ` ```tsrx demo\n<relative-path>\n``` ` 代码块引用的 demo 文件，读取真实源码。
 * 供 getDoc 调用方（页面组件）据此显式 import 对应 demo 组件进行真实渲染；
 * 本函数只负责"发现引用 + 读取源码"，不负责动态 import（tsrx 组件的 import 必须是静态的）。
 */
export function extractDemoRefs(body: string, mdFilePath: string): DemoRef[] {
  const refs: DemoRef[] = [];
  const demoBlockRegex = /```tsrx demo\n([^\n`]+)\n```/g;
  let match: RegExpExecArray | null;
  const mdDir = dirname(mdFilePath);

  while ((match = demoBlockRegex.exec(body)) !== null) {
    const relativePath = match[1]!.trim();
    const absolutePath = resolve(mdDir, relativePath);
    let source = '';
    try {
      source = readFileSync(absolutePath, 'utf-8');
    } catch {
      source = `// 未找到 demo 文件：${relativePath}`;
    }
    refs.push({
      relativePath,
      absolutePath,
      source,
      moduleId: relativePath.replace(/^\.\.\//, '').replace(/\.tsrx$/, ''),
    });
  }

  return refs;
}

export type DocFragment =
  | { type: 'html'; html: string }
  | { type: 'demo'; demo: DemoRef; highlightedSource: string };

/**
 * 把已做完 frontmatter 剥离、自定义容器处理的 markdown body 按 ` ```tsrx demo ` 代码块
 * 切分为 html/demo 交替的片段序列。
 */
function splitIntoFragments(body: string): string[] {
  const demoBlockRegex = /```tsrx demo\n[^\n`]+\n```/g;
  const parts: string[] = [];
  let lastIndex = 0;
  let match: RegExpExecArray | null;

  while ((match = demoBlockRegex.exec(body)) !== null) {
    parts.push(body.slice(lastIndex, match.index));
    parts.push('\0DEMO\0'); // 占位标记，随后按顺序对应 demos 数组
    lastIndex = match.index + match[0].length;
  }
  parts.push(body.slice(lastIndex));

  return parts;
}

function createMarked(): Marked {
  return new Marked({
    renderer: {
      heading({ tokens, depth }) {
        const text = this.parser.parseInline(tokens);
        const plainText = text.replace(/<[^>]+>/g, '').trim();
        const id = slugify(plainText);
        return `<h${depth} id="${id}" class="doc-h${depth}">${text}</h${depth}>\n`;
      },
      code({ text, lang }) {
        const language = lang || 'text';
        const highlighted = highlightCode(text, language);
        return `<div class="language-${language}"><span class="lang">${language}</span>${highlighted}</div>`;
      },
      codespan({ text }) {
        return `<code>${escapeHtml(text)}</code>`;
      },
    },
  });
}

function highlightCode(code: string, lang: string): string {
  try {
    return highlighter.codeToHtml(code, { lang, theme: 'github-light' });
  } catch {
    return `<pre class="shiki-fallback"><code>${escapeHtml(code)}</code></pre>`;
  }
}

export interface RenderedDoc {
  fragments: DocFragment[];
  frontmatter: Frontmatter;
  title: string;
  toc: TocItem[];
}

/**
 * 渲染指定 slug 对应的文档（`apps/docs/docs/<slug>.md`）为片段数组 + 元数据。
 * 供页面组件的 `module server { ... }` 块调用。同步函数——见文件头注释「关键差异二」。
 */
export function getDoc(slug: string): RenderedDoc {
  const mdPath = resolve(DOCS_ROOT, `${slug}.md`);
  const content = readFileSync(mdPath, 'utf-8');
  const { frontmatter, body } = parseFrontmatter(content);

  const demos = extractDemoRefs(body, mdPath);
  const toc = extractToc(body);
  const processedBody = processContainers(body);

  const marked = createMarked();
  const parts = splitIntoFragments(processedBody);
  const fragments: DocFragment[] = [];
  let demoIndex = 0;

  for (const part of parts) {
    if (part === '\0DEMO\0') {
      const demo = demos[demoIndex];
      demoIndex += 1;
      if (!demo) continue;
      const highlightedSource = highlightCode(demo.source, 'typescript');
      fragments.push({ type: 'demo', demo, highlightedSource });
      continue;
    }
    const trimmed = part.trim();
    if (!trimmed) continue;
    const html = marked.parse(part) as string;
    fragments.push({ type: 'html', html });
  }

  return {
    fragments,
    frontmatter,
    title: frontmatter.title ?? 'Docs',
    toc,
  };
}
