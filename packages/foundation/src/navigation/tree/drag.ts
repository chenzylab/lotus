import { findDescendantKeys, type KeyEntities } from './tree-data.js';

/** 拖拽悬停在目标节点内的相对位置：-1 落在目标前面（同级插入），
 * 0 落在目标内部（成为子节点），1 落在目标后面（同级插入）。对齐
 * Semi calcDropRelativePosition，上下各 45% 高度视为"前/后"，中间
 * 10% 视为"内部"。 */
export function calcDropRelativePosition(clientY: number, rect: { top: number; bottom: number; height: number }): -1 | 0 | 1 {
  const DRAG_OFFSET = 0.45;
  if (clientY <= rect.top + rect.height * DRAG_OFFSET) return -1;
  if (clientY >= rect.bottom - rect.height * DRAG_OFFSET) return 1;
  return 0;
}

/** 被拖拽节点自身 + 其全部后代 key——这些节点在拖拽过程中不能成为
 * dragEnter/dragOver/drop 的目标（不能把节点拖进自己的子树）。 */
export function getDragNodesKeys(key: string, entities: KeyEntities): Set<string> {
  return new Set(findDescendantKeys([key], entities, true));
}

export interface TreeDragState {
  dragging: boolean;
  dragNodeKey: string | null;
  dragNodesKeys: Set<string>;
  dragOverNodeKey: string | null;
  dropPosition: -1 | 0 | 1 | null;
}

export function createInitialDragState(): TreeDragState {
  return { dragging: false, dragNodeKey: null, dragNodesKeys: new Set(), dragOverNodeKey: null, dropPosition: null };
}
