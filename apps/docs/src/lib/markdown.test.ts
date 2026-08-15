import { describe, it, expect } from 'vitest';
import { parseFrontmatter, extractToc, extractDemoRefs, getDoc } from './markdown';
import { writeFileSync, mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

describe('parseFrontmatter', () => {
  it('parses title and category from frontmatter block', () => {
    const content = '---\ntitle: Divider 分割线\ncategory: 基础\n---\n\n## 代码演示\n';
    const { frontmatter, body } = parseFrontmatter(content);
    expect(frontmatter.title).toBe('Divider 分割线');
    expect(frontmatter.category).toBe('基础');
    expect(body.trim()).toBe('## 代码演示');
  });

  it('returns empty frontmatter and original content when no frontmatter block present', () => {
    const content = '## 代码演示\n';
    const { frontmatter, body } = parseFrontmatter(content);
    expect(frontmatter).toEqual({});
    expect(body).toBe(content);
  });
});

describe('extractToc', () => {
  it('extracts level-2 and level-3 headings only, ignoring level-1', () => {
    const body = '# 标题\n\n## 代码演示\n\n### 基础用法\n\n#### 不应被收录\n\n## API 参考\n';
    const toc = extractToc(body);
    expect(toc).toEqual([
      { href: '#代码演示', text: '代码演示', level: 2 },
      { href: '#基础用法', text: '基础用法', level: 3 },
      { href: '#api-参考', text: 'API 参考', level: 2 },
    ]);
  });

  it('strips inline code markup from heading text before slugifying', () => {
    const body = '## 使用 `Divider` 组件\n';
    const toc = extractToc(body);
    expect(toc[0]!.text).toBe('使用 Divider 组件');
  });
});

describe('extractDemoRefs', () => {
  it('finds tsrx demo code blocks and reads the referenced file content', () => {
    const dir = mkdtempSync(join(tmpdir(), 'lotus-docs-test-'));
    const demoPath = join(dir, 'demo.tsrx');
    writeFileSync(demoPath, 'export function Demo() { return <div />; }\n', 'utf-8');
    const mdPath = join(dir, 'doc.md');

    const body = [
      '## 代码演示',
      '',
      '```tsrx demo',
      './demo.tsrx',
      '```',
      '',
    ].join('\n');

    const refs = extractDemoRefs(body, mdPath);

    expect(refs).toHaveLength(1);
    expect(refs[0]!.relativePath).toBe('./demo.tsrx');
    expect(refs[0]!.source).toContain('export function Demo()');

    rmSync(dir, { recursive: true, force: true });
  });

  it('produces a placeholder source comment when the referenced demo file does not exist', () => {
    const body = '```tsrx demo\n./missing.tsrx\n```\n';
    const refs = extractDemoRefs(body, '/nonexistent/doc.md');
    expect(refs).toHaveLength(1);
    expect(refs[0]!.source).toContain('未找到 demo 文件');
  });

  it('returns an empty array when the markdown body has no demo references', () => {
    const refs = extractDemoRefs('## 代码演示\n\n没有 demo。\n', '/some/doc.md');
    expect(refs).toHaveLength(0);
  });
});

describe('getDoc (integration, against real docs/basic/divider.md)', () => {
  it('splits the document into alternating html/demo fragments matching source order', async () => {
    const doc = await getDoc('basic/divider');

    expect(doc.title).toBe('Divider 分割线');
    expect(doc.frontmatter.category).toBe('基础');

    const types = doc.fragments.map((f) => f.type);
    // divider.md 结构：intro html -> demo(basic) -> intro html -> demo(with-text) -> trailing html(info block + API + a11y + tokens)
    expect(types.filter((t) => t === 'demo')).toHaveLength(2);
    expect(types[0]).toBe('html');

    const demoFragments = doc.fragments.filter((f) => f.type === 'demo') as Array<
      Extract<(typeof doc.fragments)[number], { type: 'demo' }>
    >;
    expect(demoFragments[0]!.demo.relativePath).toContain('basic.tsrx');
    expect(demoFragments[1]!.demo.relativePath).toContain('with-text.tsrx');
    expect(demoFragments[0]!.highlightedSource).toContain('<pre'); // shiki 输出的语法高亮容器
  });

  it('renders the API reference table as HTML', async () => {
    const doc = await getDoc('basic/divider');
    const htmlFragments = doc.fragments.filter((f) => f.type === 'html') as Array<
      Extract<(typeof doc.fragments)[number], { type: 'html' }>
    >;
    const combined = htmlFragments.map((f) => f.html).join('');
    expect(combined).toContain('<table>');
    expect(combined).toContain('align');
  });

  it('extracts the TOC with 代码演示/API 参考/Accessibility/设计变量 top-level sections', async () => {
    const doc = await getDoc('basic/divider');
    const level2 = doc.toc.filter((item) => item.level === 2).map((item) => item.text);
    expect(level2).toEqual(['代码演示', 'API 参考', 'Accessibility', '设计变量']);
  });
});
