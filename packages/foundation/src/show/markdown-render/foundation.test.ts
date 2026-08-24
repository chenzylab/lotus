import { describe, expect, it } from 'vitest';
import { compileToHast, hastPropsToAttrs } from './foundation.js';
import type { Element, Root } from 'hast';

function findFirstElement(node: Root, tagName: string): Element | undefined {
  for (const child of node.children) {
    if (child.type === 'element') {
      if (child.tagName === tagName) return child;
      const found = findFirstElement({ type: 'root', children: child.children } as Root, tagName);
      if (found) return found;
    }
  }
  return undefined;
}

function textOf(node: Element): string {
  return node.children
    .map((c) => (c.type === 'text' ? c.value : c.type === 'element' ? textOf(c) : ''))
    .join('');
}

describe('compileToHast', () => {
  it('把标题编译为 h1 element 节点', async () => {
    const hast = await compileToHast('# Hello');
    const h1 = findFirstElement(hast, 'h1');
    expect(h1).toBeDefined();
    expect(textOf(h1!)).toBe('Hello');
  });

  it('把段落编译为 p element 节点', async () => {
    const hast = await compileToHast('just text');
    const p = findFirstElement(hast, 'p');
    expect(p).toBeDefined();
    expect(textOf(p!)).toBe('just text');
  });

  it('围栏代码块编译为 pre > code，code 带 language-* 类', async () => {
    const hast = await compileToHast('```ts\nconst a = 1;\n```');
    const code = findFirstElement(hast, 'code');
    expect(code).toBeDefined();
    expect((code!.properties?.className as string[]) ?? []).toContain('language-ts');
    expect(textOf(code!)).toBe('const a = 1;\n');
  });

  it('remarkGfm 默认开启：表格语法编译为 table element', async () => {
    const hast = await compileToHast('| a | b |\n| - | - |\n| 1 | 2 |');
    const table = findFirstElement(hast, 'table');
    expect(table).toBeDefined();
  });

  it('remarkGfm=false 时表格语法不被解析为 table', async () => {
    const hast = await compileToHast('| a | b |\n| - | - |\n| 1 | 2 |', { remarkGfm: false });
    const table = findFirstElement(hast, 'table');
    expect(table).toBeUndefined();
  });

  it('默认丢弃 markdown 源码里内嵌的 raw HTML（XSS 防护核心行为）', async () => {
    const hast = await compileToHast('<script>alert(1)</script>\n\ntext');
    const raw = hast.children.find((c) => c.type === 'raw');
    expect(raw).toBeUndefined();
    const scriptEl = findFirstElement(hast, 'script');
    expect(scriptEl).toBeUndefined();
  });

  it('链接编译为 a element，href 在 properties 里', async () => {
    const hast = await compileToHast('[link](https://example.com)');
    const a = findFirstElement(hast, 'a');
    expect(a).toBeDefined();
    expect(a!.properties?.href).toBe('https://example.com');
  });
});

describe('hastPropsToAttrs', () => {
  it('className 数组转为空格分隔的 class 字符串', () => {
    expect(hastPropsToAttrs({ className: ['language-ts', 'line-numbers'] })).toEqual({
      class: 'language-ts line-numbers',
    });
  });

  it('camelCase 特例属性名转为 kebab-case', () => {
    expect(hastPropsToAttrs({ colSpan: 2, tabIndex: 0 })).toEqual({
      colspan: 2,
      tabindex: 0,
    });
  });

  it('aria*/data* 属性名转为连字符形式', () => {
    expect(hastPropsToAttrs({ ariaLabel: 'foo', dataFoo: 'bar' })).toEqual({
      'aria-label': 'foo',
      'data-foo': 'bar',
    });
  });

  it('布尔 true 保留为裸属性（空字符串）', () => {
    expect(hastPropsToAttrs({ disabled: true })).toEqual({ disabled: '' });
  });

  it('null/undefined/false 值被丢弃', () => {
    expect(hastPropsToAttrs({ a: null, b: undefined, c: false, d: 'kept' })).toEqual({ d: 'kept' });
  });

  it('properties 为 undefined 时返回空对象', () => {
    expect(hastPropsToAttrs(undefined)).toEqual({});
  });

  it('未知属性名原样透传', () => {
    expect(hastPropsToAttrs({ href: 'https://x.com', title: 'hi' })).toEqual({
      href: 'https://x.com',
      title: 'hi',
    });
  });
});
