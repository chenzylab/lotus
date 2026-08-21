import { Foundation, type Adapter } from '../../base/adapter.js';
import { arrayMove } from '../../base/sortable-drag.js';
import {
  generateDataByType,
  getValuesAndItemsFromMap,
  resolveValue,
  type ResolvedDataItem,
  type TransferDataSource,
  type TransferType,
} from './transfer-data.js';
import { computeSearchResult, type TransferFilter } from './search.js';
import { calcSelectAllStatus, type SelectAllStatus } from './select-all.js';

export * from './transfer-data.js';
export * from './search.js';
export * from './select-all.js';

export interface TransferState {
  data: ResolvedDataItem[];
  selectedItems: Map<string | number, ResolvedDataItem>;
  searchResult: Set<string | number>;
  inputValue: string;
  leftCurrentPage: number;
}

export interface TransferChangeResult {
  selectedItems: Map<string | number, ResolvedDataItem>;
  values: Array<string | number>;
  items: ResolvedDataItem[];
}

/**
 * Transfer 状态机：单一数据源 + selectedItems Map 的"勾选即迁移"模型
 * （不是经典双栏移动模型——左侧渲染全量 data，右侧渲染 selectedItems 的
 * values()，勾选/取消勾选是唯一的状态变更动作，移植自 Semi
 * semi-foundation/transfer/foundation.ts 的算法思路，对齐参考实现
 * chenzy.design 已验证的同构设计）。受控/onChange 等回调按 lotus 惯例
 * （对齐 CheckboxFoundation）作为方法参数显式传入，Foundation 不持有
 * props 引用。
 *
 * 对 Semi 源码的主动修正（均已在调研阶段核实为真实存在的问题）：
 * 1. value 缺省时 fallback 到 key（见 transfer-data.ts resolveValue）；
 * 2. 搜索过滤不区分 treeList，统一走同一条 Foundation 层路径；
 * 3. 拖拽排序（handleSortEnd）与其它方法一样遵循受控检查，不无条件
 *    setState——Semi 源码这里遗漏了受控判断，是已核实的技术债。
 */
export class TransferFoundation extends Foundation<TransferState> {
  constructor(adapter: Adapter<TransferState>) {
    super(adapter);
  }

  // ===================== 数据初始化 =====================

  resolveData(dataSource: TransferDataSource, type: TransferType): ResolvedDataItem[] {
    return generateDataByType(dataSource, type);
  }

  // ===================== 搜索过滤 =====================

  /** 搜索输入变化：重置 inputValue、重算 searchResult，并把左侧分页重置到第一页。 */
  handleInputChange(input: string, filter: TransferFilter | undefined): Set<string | number> {
    const { data } = this.getState();
    const searchResult = computeSearchResult(input, data, filter);
    this.setState({ inputValue: input, searchResult, leftCurrentPage: 1 });
    return searchResult;
  }

  /** 当前可见（过滤后）数据：搜索为空时是全量 data。 */
  getVisibleData(): ResolvedDataItem[] {
    const { data, inputValue, searchResult } = this.getState();
    if (!inputValue) return data;
    return data.filter((item) => searchResult.has(item.key));
  }

  getSelectAllStatus(): SelectAllStatus {
    return calcSelectAllStatus(this.getVisibleData(), this.getState().selectedItems);
  }

  // ===================== 选中态变更 =====================

  private applySelectedItems(
    next: Map<string | number, ResolvedDataItem>,
    isControlled: boolean,
  ): TransferChangeResult {
    if (!isControlled) this.setState({ selectedItems: next });
    const { values, items } = getValuesAndItemsFromMap(next);
    return { selectedItems: next, values, items };
  }

  /**
   * 单项切换（左侧勾选 / 右侧点击移除共用同一个方法，对称的翻转选中态操作，
   * 对齐 Semi handleSelectOrRemove）。disabled 项完全拦截，不做任何变更。
   * 返回 direction 供调用方决定触发 onSelect 还是 onDeselect。
   */
  handleSelectOrRemove(
    item: ResolvedDataItem,
    isControlled: boolean,
  ): (TransferChangeResult & { direction: 'select' | 'deselect' }) | null {
    if (item.disabled) return null;
    const { selectedItems } = this.getState();
    const next = new Map(selectedItems);
    const direction = next.has(item.key) ? 'deselect' : 'select';
    if (direction === 'deselect') next.delete(item.key);
    else next.set(item.key, item);
    return { ...this.applySelectedItems(next, isControlled), direction };
  }

  /**
   * 全选/清空，对齐 Semi handleAll：操作范围限定在当前可见（过滤后）数据；
   * disabled 项在批量操作中保持不可变——已选的 disabled 项全选/清空都不会
   * 被触碰，未选的 disabled 项全选也不会被选中。
   */
  handleAll(wantAllChecked: boolean, isControlled: boolean): TransferChangeResult {
    const { selectedItems } = this.getState();
    const visibleData = this.getVisibleData();
    const next = new Map(selectedItems);
    for (const item of visibleData) {
      if (item.disabled) continue;
      if (wantAllChecked) next.set(item.key, item);
      else next.delete(item.key);
    }
    return this.applySelectedItems(next, isControlled);
  }

  // ===================== 拖拽排序（仅右侧已选列表） =====================

  /**
   * 拖拽排序：重建 Map 以改变已选列表的显示顺序。与其它方法一样遵循受控
   * 检查（修正 Semi handleSortEnd 遗漏受控判断的技术债）。
   */
  handleSortEnd(oldIndex: number, newIndex: number, isControlled: boolean): TransferChangeResult {
    const { selectedItems } = this.getState();
    const arr = arrayMove([...selectedItems.values()], oldIndex, newIndex);
    const next = new Map<string | number, ResolvedDataItem>();
    for (const item of arr) next.set(item.key, item);
    return this.applySelectedItems(next, isControlled);
  }

  // ===================== 分页（左侧） =====================

  setLeftCurrentPage(page: number): void {
    this.setState({ leftCurrentPage: page });
  }

  // ===================== 受控同步 =====================

  syncSelectedItems(values: Array<string | number>): void {
    const { data } = this.getState();
    const selectedItems = new Map<string | number, ResolvedDataItem>();
    for (const val of values) {
      const item = data.find((d) => resolveValue(d) === val);
      if (item) selectedItems.set(item.key, item);
    }
    this.setState({ selectedItems });
  }

  syncData(dataSource: TransferDataSource, type: TransferType): void {
    const data = generateDataByType(dataSource, type);
    this.setState({ data });
  }
}
