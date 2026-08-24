import { Foundation, type Adapter } from '../../base/adapter.js';
import { toggleExpandedPath, replaceNodeValue, jsonTreeToValue, type JsonNode } from './json-tree.js';

export * from './json-tree.js';

export interface JsonViewerState {
  expandedPaths: Set<string>;
}

/**
 * JsonViewer 的核心状态机：只管展开/折叠集合的读写，以及可编辑模式下
 * 叶子节点提交新值后重建树、还原成普通 JS 值两件事。树本身的构建/摊平
 * 都是纯函数（json-tree.ts），Foundation 只做状态迁移决策。
 */
export class JsonViewerFoundation extends Foundation<JsonViewerState> {
  constructor(adapter: Adapter<JsonViewerState>) {
    super(adapter);
  }

  handleToggleExpand(path: string): Set<string> {
    const { expandedPaths } = this.getState();
    const next = toggleExpandedPath(path, expandedPaths);
    this.setState({ expandedPaths: next });
    return next;
  }

  /** 叶子节点原地编辑提交：返回替换后的新树根，以及还原成普通值的结果（供 onChange 回调）。 */
  handleEditCommit(root: JsonNode, path: string, nextValue: unknown): { root: JsonNode; value: unknown } {
    const nextRoot = replaceNodeValue(root, path, nextValue);
    return { root: nextRoot, value: jsonTreeToValue(nextRoot) };
  }
}
