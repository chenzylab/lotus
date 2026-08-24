/**
 * MarkdownRender headless —— 框架无关的 Markdown → hast（HTML AST）编译。
 *
 * Semi Design 用 `@mdx-js/mdx` evaluate 把 markdown 编译成真正的 React 组件；
 * Ripple/tsrx 没有 jsx-runtime，无法复用这套机制。改用 unified 管线把
 * markdown 编译到 **hast**（不是 HTML 字符串），渲染层再递归 hast 生成真实
 * DOM 元素——全程不经过任何 HTML 字符串拼接/innerHTML，这是本组件的核心
 * XSS 防护手段（而不是引入 DOMPurify 之类的运行时 sanitizer）。
 *
 * 管线：remark-parse → 条件 remark-gfm → 透传 remarkPlugins → remark-rehype
 *       → 透传 rehypePlugins → hast root。
 *
 * 安全：remark-rehype 的 allowDangerousHtml 默认 false，markdown 源码里内嵌
 * 的 raw HTML 节点会在编译期被直接丢弃（对齐 Semi format='md' 剥离行为），
 * 不会进入 hast 树、更不会被渲染。使用方要保留 HTML 需自行传 rehype-raw
 * 并自负 XSS 风险。
 */

import type { Root as HastRoot } from 'hast';

export type { HastRoot };

/** unified 插件条目：插件本身，或 [插件, 选项] 元组，值透传给 unified。 */
export type UnifiedPluginEntry = unknown;

export interface CompileToHastOptions {
  /** 是否启用 GitHub Flavored Markdown（表格/任务列表/删除线/自动链接）。默认 true。 */
  remarkGfm?: boolean;
  /** 追加的 remark 插件（作用于 mdast，在 gfm 之后、remark-rehype 之前）。 */
  remarkPlugins?: UnifiedPluginEntry[];
  /** 追加的 rehype 插件（作用于 hast，在 remark-rehype 之后）。 */
  rehypePlugins?: UnifiedPluginEntry[];
}

interface LooseProcessor {
  use(plugin: unknown, options?: unknown): LooseProcessor;
  parse(raw: string): unknown;
  run(tree: unknown): Promise<unknown>;
}

function applyPlugin(p: LooseProcessor, entry: UnifiedPluginEntry): LooseProcessor {
  if (Array.isArray(entry)) {
    const [plugin, options] = entry as [unknown, unknown];
    return p.use(plugin, options);
  }
  return p.use(entry);
}

/**
 * 把 markdown 源码编译为 hast root（纯函数，框架无关）。
 * unified/remark/rehype 体积较大，交由渲染层自行决定加载时机（本函数本身不
 * 强制懒加载策略，只是一个 async 纯函数——渲染层可以在 effect 里调用）。
 */
export async function compileToHast(raw: string, opts: CompileToHastOptions = {}): Promise<HastRoot> {
  const { remarkGfm: enableGfm = true, remarkPlugins = [], rehypePlugins = [] } = opts;

  const [{ unified }, { default: remarkParse }, { default: remarkRehype }] = await Promise.all([
    import('unified'),
    import('remark-parse'),
    import('remark-rehype'),
  ]);

  let processor = unified().use(remarkParse) as unknown as LooseProcessor;

  if (enableGfm) {
    const { default: remarkGfm } = await import('remark-gfm');
    processor = processor.use(remarkGfm);
  }

  for (const entry of remarkPlugins) {
    processor = applyPlugin(processor, entry);
  }

  processor = processor.use(remarkRehype, { allowDangerousHtml: false });

  for (const entry of rehypePlugins) {
    processor = applyPlugin(processor, entry);
  }

  const mdast = processor.parse(raw);
  return (await processor.run(mdast)) as HastRoot;
}

const ATTR_NAME_MAP: Record<string, string> = {
  className: 'class',
  htmlFor: 'for',
  httpEquiv: 'http-equiv',
  acceptCharset: 'accept-charset',
  colSpan: 'colspan',
  rowSpan: 'rowspan',
  tabIndex: 'tabindex',
  crossOrigin: 'crossorigin',
  autoComplete: 'autocomplete',
  readOnly: 'readonly',
  maxLength: 'maxlength',
  minLength: 'minlength',
};

function toAttrName(key: string): string {
  const mapped = ATTR_NAME_MAP[key];
  if (mapped !== undefined) return mapped;
  const fifth = key[4];
  if (fifth !== undefined && key.startsWith('aria') && fifth === fifth.toUpperCase()) {
    return 'aria-' + key.slice(4).toLowerCase();
  }
  if (fifth !== undefined && key.startsWith('data') && fifth === fifth.toUpperCase()) {
    return 'data-' + key.slice(4).toLowerCase();
  }
  return key;
}

/**
 * hast properties（DOM property 命名，如 className: string[]）→ 原生 HTML
 * 属性对象（class: "a b"）。数组值用空格连接；布尔 true 保留裸属性（空字符
 * 串），false/null/undefined 丢弃。
 */
export function hastPropsToAttrs(
  properties: Record<string, unknown> | undefined,
): Record<string, string | number | boolean> {
  const out: Record<string, string | number | boolean> = {};
  if (!properties) return out;

  for (const [key, value] of Object.entries(properties)) {
    if (value === undefined || value === null || value === false) continue;
    const name = toAttrName(key);

    if (Array.isArray(value)) {
      out[name] = value.join(' ');
    } else if (value === true) {
      out[name] = '';
    } else {
      out[name] = value as string | number;
    }
  }
  return out;
}
