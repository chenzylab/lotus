import { describe, expect, it } from 'vitest';
import { JsonViewerFoundation, buildJsonTree, type JsonViewerState } from './foundation.js';

function createFoundation(initial: JsonViewerState) {
  let state = initial;
  const foundation = new JsonViewerFoundation({
    getState: () => state,
    setState: (patch) => {
      state = { ...state, ...patch };
    },
  });
  return { foundation, getState: () => state };
}

describe('JsonViewerFoundation', () => {
  it('handleToggleExpand 切换展开集合并同步写回状态', () => {
    const { foundation, getState } = createFoundation({ expandedPaths: new Set(['root']) });
    const next = foundation.handleToggleExpand('root.a');
    expect(next).toEqual(new Set(['root', 'root.a']));
    expect(getState().expandedPaths).toEqual(new Set(['root', 'root.a']));
  });

  it('handleToggleExpand 对已展开路径再次调用即折叠', () => {
    const { foundation } = createFoundation({ expandedPaths: new Set(['root', 'root.a']) });
    const next = foundation.handleToggleExpand('root.a');
    expect(next).toEqual(new Set(['root']));
  });

  it('handleEditCommit 替换叶子值并还原成完整 JS 值', () => {
    const { foundation } = createFoundation({ expandedPaths: new Set(['root']) });
    const root = buildJsonTree({ a: 1, b: 2 });
    const { root: nextRoot, value } = foundation.handleEditCommit(root, 'root.a', 999);
    expect(value).toEqual({ a: 999, b: 2 });
    expect(nextRoot.children[0]!.value).toBe(999);
  });
});
