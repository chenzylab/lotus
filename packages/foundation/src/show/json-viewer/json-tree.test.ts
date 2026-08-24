import { describe, expect, it } from 'vitest';
import {
  buildJsonTree,
  parseToJsonTree,
  getJsonValueType,
  calcDefaultExpandedPaths,
  calcAllExpandedPaths,
  toggleExpandedPath,
  replaceNodeValue,
  jsonTreeToValue,
} from './json-tree.js';

describe('getJsonValueType', () => {
  it('识别 object/array/string/number/boolean/null 六种类型', () => {
    expect(getJsonValueType({})).toBe('object');
    expect(getJsonValueType([])).toBe('array');
    expect(getJsonValueType('a')).toBe('string');
    expect(getJsonValueType(1)).toBe('number');
    expect(getJsonValueType(true)).toBe('boolean');
    expect(getJsonValueType(null)).toBe('null');
  });
});

describe('buildJsonTree', () => {
  it('对象构建出带 root 路径与逐层 key 路径的子节点', () => {
    const root = buildJsonTree({ a: 1, b: 'x' });
    expect(root.path).toBe('root');
    expect(root.type).toBe('object');
    expect(root.children.map((c) => c.path)).toEqual(['root.a', 'root.b']);
    expect(root.children[0]!.key).toBe('a');
    expect(root.children[0]!.value).toBe(1);
  });

  it('数组用下标拼接路径', () => {
    const root = buildJsonTree([10, 20]);
    expect(root.type).toBe('array');
    expect(root.children.map((c) => c.path)).toEqual(['root[0]', 'root[1]']);
  });

  it('嵌套结构递归生成正确的路径与 level', () => {
    const root = buildJsonTree({ a: [{ b: 1 }] });
    const arr = root.children[0]!;
    expect(arr.path).toBe('root.a');
    const obj = arr.children[0]!;
    expect(obj.path).toBe('root.a[0]');
    const leaf = obj.children[0]!;
    expect(leaf.path).toBe('root.a[0].b');
    expect(leaf.level).toBe(3);
  });

  it('叶子节点 children 为空数组', () => {
    const root = buildJsonTree(42);
    expect(root.children).toEqual([]);
    expect(root.value).toBe(42);
  });
});

describe('parseToJsonTree', () => {
  it('已解析的值直接构建树', () => {
    const root = parseToJsonTree({ a: 1 });
    expect(root?.type).toBe('object');
  });

  it('合法 JSON 字符串解析后构建树', () => {
    const root = parseToJsonTree('{"a":1}');
    expect(root?.children[0]!.value).toBe(1);
  });

  it('非法 JSON 字符串返回 null', () => {
    expect(parseToJsonTree('{invalid')).toBeNull();
  });
});

describe('calcDefaultExpandedPaths', () => {
  it('depth=1 时只展开根节点', () => {
    const root = buildJsonTree({ a: { b: { c: 1 } } });
    const expanded = calcDefaultExpandedPaths(root, 1);
    expect(expanded).toEqual(new Set(['root']));
  });

  it('depth=2 时展开根节点与第一层容器节点', () => {
    const root = buildJsonTree({ a: { b: { c: 1 } } });
    const expanded = calcDefaultExpandedPaths(root, 2);
    expect(expanded).toEqual(new Set(['root', 'root.a']));
  });

  it('depth=0 时全部折叠', () => {
    const root = buildJsonTree({ a: 1 });
    expect(calcDefaultExpandedPaths(root, 0)).toEqual(new Set());
  });
});

describe('calcAllExpandedPaths', () => {
  it('展开树上全部容器节点路径，不含叶子节点', () => {
    const root = buildJsonTree({ a: { b: 1 }, c: [1, 2] });
    const expanded = calcAllExpandedPaths(root);
    expect(expanded).toEqual(new Set(['root', 'root.a', 'root.c']));
  });
});

describe('toggleExpandedPath', () => {
  it('不存在时加入，存在时移除，返回新集合不修改原集合', () => {
    const original = new Set(['root']);
    const added = toggleExpandedPath('root.a', original);
    expect(added).toEqual(new Set(['root', 'root.a']));
    expect(original).toEqual(new Set(['root']));

    const removed = toggleExpandedPath('root', added);
    expect(removed).toEqual(new Set(['root.a']));
  });
});

describe('replaceNodeValue', () => {
  it('替换根节点本身的值', () => {
    const root = buildJsonTree(1);
    const next = replaceNodeValue(root, 'root', 2);
    expect(next.value).toBe(2);
  });

  it('替换嵌套路径的叶子值，不影响其它分支', () => {
    const root = buildJsonTree({ a: 1, b: 2 });
    const next = replaceNodeValue(root, 'root.a', 100);
    expect(jsonTreeToValue(next)).toEqual({ a: 100, b: 2 });
    // 未变化的分支节点引用应保持不变（避免不必要的重渲染）。
    expect(next.children[1]).toBe(root.children[1]);
  });

  it('路径前缀相似但不同的兄弟节点不会被误判替换（如 root.a 与 root.ab）', () => {
    const root = buildJsonTree({ a: 1, ab: 2 });
    const next = replaceNodeValue(root, 'root.a', 100);
    expect(jsonTreeToValue(next)).toEqual({ a: 100, ab: 2 });
  });

  it('数组下标路径正确替换', () => {
    const root = buildJsonTree([1, 2, 3]);
    const next = replaceNodeValue(root, 'root[1]', 200);
    expect(jsonTreeToValue(next)).toEqual([1, 200, 3]);
  });

  it('找不到路径时原样返回根（引用不变）', () => {
    const root = buildJsonTree({ a: 1 });
    const next = replaceNodeValue(root, 'root.nonexistent', 100);
    expect(next).toBe(root);
  });
});

describe('jsonTreeToValue', () => {
  it('把树还原成与原始输入等价的 JS 值', () => {
    const original = { a: 1, b: [1, 2, { c: 'x' }], d: null, e: true };
    const root = buildJsonTree(original);
    expect(jsonTreeToValue(root)).toEqual(original);
  });
});
