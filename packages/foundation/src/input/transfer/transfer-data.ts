/**
 * Transfer 数据归一化：把三种 dataSource 形态（扁平列表/分组/树）统一打平成
 * 一份 ResolvedDataItem[]，移植自 Semi semi-foundation/transfer/transferUtils.ts
 * 的 _generateDataByType 思路。key 是内部身份标识（Map 键），value 缺省时
 * fallback 到 key（Semi 源码没有这个 fallback，是已核实的真实缺陷——见调研
 * 报告第5.1.3节——lotus 主动修正，避免 value 未设置时受控 value 数组永远
 * 匹配不上的隐藏坑）。
 */

export interface BasicDataItem {
  key: string | number;
  label?: string;
  value?: string | number;
  disabled?: boolean;
}

export interface GroupItem {
  title: string;
  children: BasicDataItem[];
}

export interface TreeItem extends BasicDataItem {
  children?: TreeItem[];
}

export type TransferDataSource = BasicDataItem[] | GroupItem[] | TreeItem[];
export type TransferType = 'list' | 'groupList' | 'treeList';

export interface ResolvedDataItem extends BasicDataItem {
  _parent?: { title: string };
  path?: BasicDataItem[];
  isLeaf?: boolean;
}

/** value 缺省时 fallback 到 key（lotus 对 Semi 已知缺陷的主动修正）。 */
export function resolveValue(item: BasicDataItem): string | number {
  return item.value ?? item.key;
}

function generateGroupedData(dataSource: GroupItem[]): ResolvedDataItem[] {
  const result: ResolvedDataItem[] = [];
  for (const group of dataSource) {
    for (const child of group.children) {
      result.push({ ...child, _parent: { title: group.title } });
    }
  }
  return result;
}

/** 迭代式 DFS（显式栈，避免深树递归栈溢出），打平树形数据并注入 path/isLeaf。 */
function generateTreeData(dataSource: TreeItem[]): ResolvedDataItem[] {
  const result: ResolvedDataItem[] = [];
  const stack: Array<{ node: TreeItem; path: BasicDataItem[] }> = [];
  for (let i = dataSource.length - 1; i >= 0; i--) {
    stack.push({ node: dataSource[i]!, path: [] });
  }
  while (stack.length > 0) {
    const { node, path } = stack.pop()!;
    const { children, ...rest } = node;
    const nextPath = [...path, rest];
    const isLeaf = !children || children.length === 0;
    result.push({ ...rest, path: nextPath, isLeaf });
    if (children) {
      for (let i = children.length - 1; i >= 0; i--) {
        stack.push({ node: children[i]!, path: nextPath });
      }
    }
  }
  return result;
}

export function generateDataByType(dataSource: TransferDataSource, type: TransferType): ResolvedDataItem[] {
  if (type === 'groupList') return generateGroupedData(dataSource as GroupItem[]);
  if (type === 'treeList') return generateTreeData(dataSource as TreeItem[]);
  return (dataSource as BasicDataItem[]).slice();
}

/** value 数组 → selectedItems Map（受控 value / defaultValue 初始化用）。 */
export function generateSelectedItems(
  values: Array<string | number>,
  data: ResolvedDataItem[],
): Map<string | number, ResolvedDataItem> {
  const selectedItems = new Map<string | number, ResolvedDataItem>();
  for (const val of values) {
    const item = data.find((d) => resolveValue(d) === val);
    if (item) selectedItems.set(item.key, item);
  }
  return selectedItems;
}

/** selectedItems Map → 对外 onChange 的 (values, items) 二元组。 */
export function getValuesAndItemsFromMap(
  selectedItems: Map<string | number, ResolvedDataItem>,
): { values: Array<string | number>; items: ResolvedDataItem[] } {
  const items = [...selectedItems.values()];
  const values = items.map((item) => resolveValue(item));
  return { values, items };
}
