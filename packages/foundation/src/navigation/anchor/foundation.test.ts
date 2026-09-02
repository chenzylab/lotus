import { describe, it, expect } from 'vitest';
import { flattenLinks, resolveActiveLink, shouldShowInCollapse, sortRegisteredLinks, type AnchorLinkInput } from './foundation.js';

describe('flattenLinks', () => {
  it('无嵌套时原样摊平，level 全为 0', () => {
    const links: AnchorLinkInput[] = [{ href: '#a', title: 'A' }, { href: '#b', title: 'B' }];
    const result = flattenLinks(links);

    expect(result).toEqual([
      { href: '#a', title: 'A', disabled: undefined, level: 0, ancestorHrefs: [] },
      { href: '#b', title: 'B', disabled: undefined, level: 0, ancestorHrefs: [] },
    ]);
  });

  it('嵌套子项摊平后紧跟在父项之后，level 递增，ancestorHrefs 记录祖先链', () => {
    const links: AnchorLinkInput[] = [
      { href: '#a', title: 'A', children: [{ href: '#a1', title: 'A1' }] },
      { href: '#b', title: 'B' },
    ];
    const result = flattenLinks(links);

    expect(result.map((l) => l.href)).toEqual(['#a', '#a1', '#b']);
    expect(result.map((l) => l.level)).toEqual([0, 1, 0]);
    expect(result.map((l) => l.ancestorHrefs)).toEqual([[], ['#a'], []]);
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
    expect(result.map((l) => l.ancestorHrefs)).toEqual([[], ['#a'], ['#a', '#a1']]);
  });

  it('空数组返回空结果', () => {
    expect(flattenLinks([])).toEqual([]);
  });

  it('disabled 字段透传到摊平结果', () => {
    const links: AnchorLinkInput[] = [{ href: '#a', title: 'A', disabled: true }];
    expect(flattenLinks(links)[0]!.disabled).toBe(true);
  });
});

describe('sortRegisteredLinks', () => {
  it('同一父节点下：子节点先于父节点注册时，仍按注册表内子节点相对顺序紧跟在父节点之后（深度优先）', () => {
    // 模拟 Ripple 子组件先于父组件 mount 的真实注册顺序——顶层兄弟
    // （parentHref 相同为 null）之间的相对顺序取决于各自 effect 的
    // 注册时序而非本函数，这里 #a 排在 #b 之前是因为输入数组本身
    // #a 在前；本函数只保证"同一父节点下，父节点后紧跟其全部子节点"。
    const links = [
      { href: '#a1', title: 'A1', level: 1, parentHref: '#a' },
      { href: '#a', title: 'A', level: 0, parentHref: null },
      { href: '#a2', title: 'A2', level: 1, parentHref: '#a' },
      { href: '#b', title: 'B', level: 0, parentHref: null },
    ];
    const result = sortRegisteredLinks(links);

    expect(result.map((l) => l.href)).toEqual(['#a', '#a1', '#a2', '#b']);
  });

  it('多级嵌套正确计算 ancestorHrefs', () => {
    const links = [
      { href: '#a', title: 'A', level: 0, parentHref: null },
      { href: '#a1', title: 'A1', level: 1, parentHref: '#a' },
      { href: '#a1a', title: 'A1a', level: 2, parentHref: '#a1' },
    ];
    const result = sortRegisteredLinks(links);

    expect(result.map((l) => l.ancestorHrefs)).toEqual([[], ['#a'], ['#a', '#a1']]);
  });

  it('空数组返回空结果', () => {
    expect(sortRegisteredLinks([])).toEqual([]);
  });
});

describe('shouldShowInCollapse', () => {
  it('顶层链接（无祖先）始终显示', () => {
    expect(shouldShowInCollapse({ ancestorHrefs: [] }, null, [])).toBe(true);
  });

  it('直接父级是当前激活链接时显示', () => {
    expect(shouldShowInCollapse({ ancestorHrefs: ['#a'] }, '#a', [])).toBe(true);
  });

  it('直接父级在激活链接的祖先链上时显示', () => {
    expect(shouldShowInCollapse({ ancestorHrefs: ['#a', '#a1'] }, '#a1a', ['#a', '#a1'])).toBe(true);
  });

  it('直接父级既不是激活链接也不在其祖先链上时隐藏', () => {
    expect(shouldShowInCollapse({ ancestorHrefs: ['#b'] }, '#a', [])).toBe(false);
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
