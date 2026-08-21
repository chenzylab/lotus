/**
 * 展开行/树形数据打平，移植自 Semi bodyFoundation.ts flattenData 的算法
 * 思路：树形数据（record 上有 childrenKey 字段）和自定义展开行内容
 * （expandedRowRender）是同一套机制——子节点存在则递归打平子行，否则
 * （且传了 expandedRowRender）打平出一条合成的展开内容行，共用同一个
 * expandedRowKeys 状态驱动，不是两套独立实现（调研已核实 Semi 官方就是
 * 这样设计的，lotus 忠实对齐）。
 */

export interface FlatRow<T = any> {
  key: string;
  record: T;
  level: number;
  /** 合成的"展开内容"行（expandedRowRender 场景），不是真实数据行。 */
  isExpandedContent: boolean;
  /** 该行是否有子节点（决定要不要渲染展开图标）。 */
  hasChildren: boolean;
}

export interface FlattenOptions<T = any> {
  rowKey: (record: T, index: number) => string;
  childrenKey: string;
  expandedRowKeys: Set<string>;
  hasExpandedRowRender: boolean;
}

export function flattenRows<T = any>(data: T[], options: FlattenOptions<T>): FlatRow<T>[] {
  const { rowKey, childrenKey, expandedRowKeys, hasExpandedRowRender } = options;
  const result: FlatRow<T>[] = [];

  function walk(rows: T[], level: number, baseIndex: number) {
    rows.forEach((record, i) => {
      const key = rowKey(record, baseIndex + i);
      const children = (record as any)[childrenKey] as T[] | undefined;
      const hasChildren = !!children?.length;
      result.push({ key, record, level, isExpandedContent: false, hasChildren });

      if (!expandedRowKeys.has(key)) return;
      if (hasChildren) {
        walk(children!, level + 1, 0);
      } else if (hasExpandedRowRender) {
        result.push({ key: `${key}__expanded`, record, level: level + 1, isExpandedContent: true, hasChildren: false });
      }
    });
  }

  walk(data, 0, 0);
  return result;
}

export function toggleExpandedRow(expandedRowKeys: Set<string>, key: string): Set<string> {
  const next = new Set(expandedRowKeys);
  if (next.has(key)) next.delete(key);
  else next.add(key);
  return next;
}
