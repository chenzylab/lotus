/**
 * 数据分组，移植自 Semi semi-foundation/table/foundation.ts groupDataSource 的
 * 算法思路：groupBy 只是把 dataSource 按分组键重新排列（同组数据聚在一起），
 * 不产生嵌套结构——分组标题行的插入是渲染层的事（遍历 groups 顺序，在每组
 * 数据前插入一行合成的标题行），Foundation 只负责算出「组顺序 + 组内成员
 * key 集合」这份最小信息。
 *
 * 展开态复用 Table 现有的 expandedRowKeys（Set<string>）机制——分组标题行的
 * groupKey 和普通行 key 共存同一个 Set，不是独立的第二套展开状态（调研已
 * 核实 Semi 官方就是这样共用一套 handleRowExpanded 的）。
 */

export type GroupByFn<T = any> = (record: T) => string | number;
export type GroupBy<T = any> = string | GroupByFn<T>;

export interface GroupResult<T = any> {
  /** 分组后的 groupKey 出现顺序（Map 保留插入顺序，即首次遇到该组的顺序）。 */
  groupKeys: string[];
  /** 每组包含的成员行 key 集合。 */
  groups: Map<string, Set<string>>;
  /** 按分组重新排列后的 dataSource（同组数据聚在一起，组内保持原有相对顺序）。 */
  dataSource: T[];
}

/** 对一批数据按 groupBy 分组：字符串按字段取值，函数直接调用。groupKey 为
 * null/undefined/空字符串的记录不进入任何组，保留在结果里但不参与分组渲染
 * （对齐 Semi：这类记录只是「不分组」，不是被丢弃）。 */
export function groupDataSource<T = any>(
  dataSource: T[],
  groupBy: GroupBy<T> | undefined,
  resolveKey: (record: T, index: number) => string,
): GroupResult<T> {
  if (groupBy == null) {
    return { groupKeys: [], groups: new Map(), dataSource };
  }

  const groups = new Map<string, Set<string>>();
  const groupKeys: string[] = [];
  const ungrouped: T[] = [];

  dataSource.forEach((record, index) => {
    const raw = typeof groupBy === 'function' ? groupBy(record) : (record as any)[groupBy];
    if (raw == null || raw === '') {
      ungrouped.push(record);
      return;
    }
    const groupKey = String(raw);
    const recordKey = resolveKey(record, index);
    let set = groups.get(groupKey);
    if (!set) {
      set = new Set();
      groups.set(groupKey, set);
      groupKeys.push(groupKey);
    }
    set.add(recordKey);
  });

  if (groups.size === 0) {
    return { groupKeys: [], groups, dataSource };
  }

  const byKey = new Map<string, T>();
  dataSource.forEach((record, index) => byKey.set(resolveKey(record, index), record));

  const reordered: T[] = [];
  groupKeys.forEach((groupKey) => {
    for (const recordKey of groups.get(groupKey)!) {
      const record = byKey.get(recordKey);
      if (record !== undefined) reordered.push(record);
    }
  });
  reordered.push(...ungrouped);

  return { groupKeys, groups, dataSource: reordered };
}

export interface GroupSection<T = any> {
  groupKey: string;
  /** 组内成员记录（原始顺序，交给渲染层继续走排序/展开/树形打平）。 */
  members: T[];
}

/** 按 groupKeys 顺序把分组结果拆成「组标题 + 组内成员」的分段列表，供渲染层
 * 逐组插入标题行、组内成员各自走完整的 flattenRows 管线（树形/展开行在
 * 分组场景下仍然要生效——两者是正交的能力，不是互斥关系）。 */
export function buildGroupSections<T = any>(
  result: GroupResult<T>,
  resolveKey: (record: T, index: number) => string,
): GroupSection<T>[] {
  const byKey = new Map<string, T>();
  result.dataSource.forEach((record, index) => byKey.set(resolveKey(record, index), record));

  return result.groupKeys.map((groupKey) => {
    const memberKeys = result.groups.get(groupKey)!;
    const members: T[] = [];
    for (const key of memberKeys) {
      const record = byKey.get(key);
      if (record !== undefined) members.push(record);
    }
    return { groupKey, members };
  });
}

/** 把分组结果打平成一份完整的 FlatRow 序列：每组前插入一行合成的分组标题
 * （isGroupSection），标题行收起时跳过组内成员（clickGroupedRowToExpand
 * 只影响标题行本身的点击触发方式，不影响这里的收起/展开判断——两者都读
 * 同一个 expandedRowKeys）；未分组的剩余记录（groupBy 取不到值的行）原样
 * 打平在所有分组段之后，不包一层标题。 */
export function flattenGroupedRows<T = any>(
  result: GroupResult<T>,
  resolveKey: (record: T, index: number) => string,
  options: {
    expandedRowKeys: Set<string>;
    flattenMembers: (members: T[]) => import('./expand.js').FlatRow<T>[];
  },
): import('./expand.js').FlatRow<T>[] {
  const { expandedRowKeys, flattenMembers } = options;
  const sections = buildGroupSections(result, resolveKey);
  const membersByGroup = new Map<string, T[]>();
  result.groupKeys.forEach((groupKey, i) => membersByGroup.set(groupKey, sections[i]!.members));

  const rows: import('./expand.js').FlatRow<T>[] = [];
  result.groupKeys.forEach((groupKey) => {
    const expanded = expandedRowKeys.has(groupKey);
    rows.push({
      key: groupKey,
      record: undefined as any,
      level: 0,
      isExpandedContent: false,
      hasChildren: false,
      displayNone: false,
      isGroupSection: true,
      groupKey,
    });
    if (!expanded) return;
    rows.push(...flattenMembers(membersByGroup.get(groupKey) ?? []));
  });

  return rows;
}
