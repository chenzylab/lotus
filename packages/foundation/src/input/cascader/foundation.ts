import { Foundation, type Adapter } from '../../base/adapter.js';
import { calcCheckedKeysForChecked, calcCheckedKeysForUnchecked, calcCheckedKeys } from '../../navigation/tree/check-cascade.js';
import type { KeyEntities } from '../../navigation/tree/tree-data.js';
import {
  computeColumns,
  findAncestorKeys,
  isLeafEntity,
  joinValuePath,
  type CascaderEntities,
  type CascaderNodeData,
} from './cascader-data.js';
import { collapseCheckedKeysToValuePaths } from './value.js';
import { computeCascaderSearchResult, type CascaderFilterTreeNode, type CascaderSearchItem } from './search.js';

export * from './cascader-data.js';
export * from './value.js';
export * from './search.js';

export interface CascaderState {
  /** 当前激活路径上所有 key 的集合（对齐 Semi：驱动多列面板展开到第几级，
   * 不是"哪些列被展开"这种一对多语义，而是单一路径链）。 */
  activeKeys: Set<string>;
  /** 单选态：当前选中路径的 key（叶子或 changeOnSelect 时的中间节点）。 */
  selectedKey: string | null;
  /** 多选态：三态级联算出的内部选中集合，对外 value 需经 collapseCheckedKeysToValuePaths 折叠。 */
  checkedKeys: Set<string>;
  halfCheckedKeys: Set<string>;
  searchInput: string;
  loadingKeys: Set<string>;
  loadedKeys: Set<string>;
}

function toKeyEntities(entities: CascaderEntities): KeyEntities {
  // 安全转换：calcCheckedKeysForChecked/Unchecked 及其内部调用的
  // findAncestorKeys/findDescendantKeys/findSiblingKeys 运行时只读取
  // key/parent/children 三个字段，从不访问 .data，CascaderEntity 在这三个
  // 字段上与 KeyEntity 结构完全一致（详见 cascader-data.ts 顶部注释）。
  return entities as unknown as KeyEntities;
}

/**
 * Cascader 的核心状态机：多列级联面板的激活路径、单选/多选（含三态级联）、
 * 搜索、loadData 异步懒加载。三态级联算法直接复用 Tree 的
 * calcCheckedKeysForChecked/Unchecked（Semi 源码本身也是这么做的——Cascader
 * 内部 import 自 semi-foundation/tree/treeUtil，两者是同一份算法）。
 */
export class CascaderFoundation extends Foundation<CascaderState> {
  constructor(adapter: Adapter<CascaderState>) {
    super(adapter);
  }

  /** hover/click 展开下一级：把 activeKeys 设为该节点的完整路径（对齐 Semi
   * `handleItemHover`/`handleItemClick` 的 activeKeys = path 语义）。 */
  handleActivate(key: string, entities: CascaderEntities): Set<string> {
    const next = new Set(findAncestorKeys([key], entities, true));
    this.setState({ activeKeys: next });
    return next;
  }

  /** 单选选中：非叶子节点默认不可选中（除非 changeOnSelect），叶子节点选中
   * 后通常同时收起浮层（由 Adapter/组件层决定，Foundation 只更新状态）。 */
  handleSingleSelect(key: string, entities: CascaderEntities, changeOnSelect = false): { selectedKey: string | null; canClose: boolean } {
    const entity = entities[key];
    if (!entity) return { selectedKey: null, canClose: false };
    const isLeaf = isLeafEntity(entity);
    if (!isLeaf && !changeOnSelect) {
      this.handleActivate(key, entities);
      return { selectedKey: null, canClose: false };
    }
    this.setState({ selectedKey: key, activeKeys: new Set(findAncestorKeys([key], entities, true)) });
    return { selectedKey: key, canClose: isLeaf };
  }

  /** 多选勾选切换：三态级联计算 + 同步展开该节点路径（对齐 Semi 点击即联动展开下一级）。
   * `checkRelation='unRelated'` 时绕开三态级联，只做当前 key 的单点增删。 */
  handleMultipleCheck(
    key: string,
    entities: CascaderEntities,
    checkRelation: 'related' | 'unRelated' = 'related',
  ): { checkedKeys: Set<string>; halfCheckedKeys: Set<string> } {
    const { checkedKeys, halfCheckedKeys } = this.getState();
    const isChecked = checkedKeys.has(key);

    if (checkRelation === 'unRelated') {
      const nextChecked = new Set(checkedKeys);
      if (isChecked) nextChecked.delete(key);
      else nextChecked.add(key);
      const result = { checkedKeys: nextChecked, halfCheckedKeys: new Set(halfCheckedKeys) };
      this.setState(result);
      return result;
    }

    const keyEntities = toKeyEntities(entities);
    const result = isChecked
      ? calcCheckedKeysForUnchecked(key, keyEntities, checkedKeys, halfCheckedKeys)
      : calcCheckedKeysForChecked(key, keyEntities, checkedKeys, halfCheckedKeys);
    this.setState(result);
    return result;
  }

  /** 受控 value/defaultValue（多选，二维 valuePath 数组）变化时全量重算内部
   * 选中态——对应 Semi 的"从外部 value 反推 checkedKeys"初始化路径。 */
  syncCheckedKeysFromValue(valuePaths: Array<Array<string | number>>, entities: CascaderEntities): { checkedKeys: Set<string>; halfCheckedKeys: Set<string> } {
    const keys = valuePaths.map((path) => joinValuePath(path)).filter((key) => entities[key]);
    const keyEntities = toKeyEntities(entities);
    const result = calcCheckedKeys(keys, keyEntities);
    this.setState(result);
    return result;
  }

  resolveValue(entities: CascaderEntities, options: { autoMergeValue?: boolean; leafOnly?: boolean } = {}): Array<Array<string | number>> {
    const { checkedKeys } = this.getState();
    return collapseCheckedKeysToValuePaths(checkedKeys, entities, options);
  }

  computeColumns(rootData: CascaderNodeData[], entities: CascaderEntities): ReturnType<typeof computeColumns> {
    const { activeKeys } = this.getState();
    return computeColumns(rootData, activeKeys, entities);
  }

  handleSearch(input: string, entities: CascaderEntities, filterTreeNode: CascaderFilterTreeNode, options?: { separator?: string; filterLeafOnly?: boolean }): CascaderSearchItem[] {
    this.setState({ searchInput: input });
    return computeCascaderSearchResult(input, entities, filterTreeNode, options);
  }

  handleLoadStart(key: string): void {
    const { loadingKeys } = this.getState();
    this.setState({ loadingKeys: new Set([...loadingKeys, key]) });
  }

  handleLoadEnd(key: string, success: boolean): void {
    const { loadingKeys, loadedKeys } = this.getState();
    const nextLoading = new Set(loadingKeys);
    nextLoading.delete(key);
    const nextLoaded = success ? new Set([...loadedKeys, key]) : loadedKeys;
    this.setState({ loadingKeys: nextLoading, loadedKeys: nextLoaded });
  }
}
