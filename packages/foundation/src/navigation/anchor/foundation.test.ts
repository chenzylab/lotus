import { describe, it, expect } from 'vitest';
import { flattenLinks, resolveActiveLink, type AnchorLinkInput } from './foundation.js';

describe('flattenLinks', () => {
  it('无嵌套时原样摊平，level 全为 0', () => {
    const links: AnchorLinkInput[] = [{ href: '#a', title: 'A' }, { href: '#b', title: 'B' }];
    const result = flattenLinks(links);

    expect(result).toEqual([
      { href: '#a', title: 'A', level: 0 },
      { href: '#b', title: 'B', level: 0 },
    ]);
  });

  it('嵌套子项摊平后紧跟在父项之后，level 递增', () => {
    const links: AnchorLinkInput[] = [
      { href: '#a', title: 'A', children: [{ href: '#a1', title: 'A1' }] },
      { href: '#b', title: 'B' },
    ];
    const result = flattenLinks(links);

    expect(result.map((l) => l.href)).toEqual(['#a', '#a1', '#b']);
    expect(result.map((l) => l.level)).toEqual([0, 1, 0]);
  });

  it('多级嵌套（3层）正确递归摊平', () => {
    const links: AnchorLinkInput[] = [
      {
        href: '#a',
        title: 'A',
        children: [{ href: '#a1', title: 'A1', children: [{ href: '#a1a', title: 'A1a' }] }],
      },
    ];
    const result = flattenLinks(links);

    expect(result.map((l) => l.href)).toEqual(['#a', '#a1', '#a1a']);
    expect(result.map((l) => l.level)).toEqual([0, 1, 2]);
  });

  it('空数组返回空结果', () => {
    expect(flattenLinks([])).toEqual([]);
  });
});

describe('resolveActiveLink', () => {
  it('全部 top >= 0（尚未滚过任何 section）时返回 null', () => {
    expect(resolveActiveLink(['#a', '#b', '#c'], [10, 50, 100])).toBeNull();
  });

  it('找到最后一个 top < 0 的项（最接近 0 的负值）作为高亮项', () => {
    // #a 已滚过很远（-500），#b 刚滚过（-20），#c 还没到（80）
    expect(resolveActiveLink(['#a', '#b', '#c'], [-500, -20, 80])).toBe('#b');
  });

  it('只有第一项 top < 0 时高亮第一项', () => {
    expect(resolveActiveLink(['#a', '#b'], [-10, 50])).toBe('#a');
  });

  it('全部 top < 0 时高亮最后一项（滚到底部之后）', () => {
    expect(resolveActiveLink(['#a', '#b', '#c'], [-300, -200, -50])).toBe('#c');
  });

  it('top 恰好等于 0 的项不算"已滚过"（严格小于 0 才算）', () => {
    expect(resolveActiveLink(['#a', '#b'], [0, 50])).toBeNull();
  });

  it('空数组返回 null', () => {
    expect(resolveActiveLink([], [])).toBeNull();
  });
});
