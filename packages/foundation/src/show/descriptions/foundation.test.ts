import { describe, it, expect } from 'vitest';
import { groupByColumn, filterVisible, type DescriptionsItemData } from './foundation.js';

function item(key: string, span?: number, hidden?: boolean): DescriptionsItemData {
  return { key, value: `${key}-value`, span, hidden };
}

describe('groupByColumn', () => {
  it('span 均为默认值 1 时，按 column 数量整除分组', () => {
    const items = [item('a'), item('b'), item('c'), item('d')];
    const groups = groupByColumn(items, 2);

    expect(groups).toHaveLength(2);
    expect(groups[0]!.map((i) => i.key)).toEqual(['a', 'b']);
    expect(groups[1]!.map((i) => i.key)).toEqual(['c', 'd']);
  });

  it('span 总和超过 column 时立即换行（不会拆分单个 item）', () => {
    const items = [item('a', 2), item('b'), item('c')];
    const groups = groupByColumn(items, 2);

    // a 的 span=2 已经等于 column，单独成组
    expect(groups[0]!.map((i) => i.key)).toEqual(['a']);
    expect(groups[1]!.map((i) => i.key)).toEqual(['b', 'c']);
  });

  it('最后一组未显式指定 span 时自动撑满剩余列数', () => {
    const items = [item('a'), item('b'), item('c')];
    const groups = groupByColumn(items, 3);

    // a+b+c 共 3 个 item，span 均为 1，总和 3 达到 column，直接成组，不需要撑满
    expect(groups).toHaveLength(1);
    expect(groups[0]!.map((i) => i.key)).toEqual(['a', 'b', 'c']);
  });

  it('最后一组总和不足 column 时，最后一项 span 被补齐撑满整行', () => {
    const items = [item('a'), item('b')];
    const groups = groupByColumn(items, 3);

    expect(groups).toHaveLength(1);
    expect(groups[0]).toHaveLength(2);
    expect(groups[0]![0]!.span).toBeUndefined();
    // b 原本 span 未指定，总和 2 < column 3，补齐为 3 - 2 + 1 = 2
    expect(groups[0]![1]!.span).toBe(2);
  });

  it('最后一项已显式指定 span 时不做自动撑满', () => {
    const items = [item('a'), item('b', 1)];
    // 手动把 b 的 span 显式设为非 undefined，模拟"用户主动指定了 span=1"
    const groups = groupByColumn(items, 3);

    expect(groups[0]![1]!.span).toBe(1);
  });

  it('hidden 的 item 不参与分组', () => {
    const items = [item('a'), item('b', undefined, true), item('c')];
    const groups = groupByColumn(items, 2);

    const allKeys = groups.flat().map((i) => i.key);
    expect(allKeys).toEqual(['a', 'c']);
  });

  it('空数组返回空分组', () => {
    expect(groupByColumn([], 3)).toEqual([]);
  });
});

describe('filterVisible', () => {
  it('过滤掉 hidden 为 true 的 item，保留其余顺序', () => {
    const items = [item('a'), item('b', undefined, true), item('c')];
    expect(filterVisible(items).map((i) => i.key)).toEqual(['a', 'c']);
  });
});
