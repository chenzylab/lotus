export interface CascaderNodeData {
  value: string | number;
  label: any;
  disabled?: boolean;
  isLeaf?: boolean;
  children?: CascaderNodeData[];
}

/** 路径拼接生成 key 的分隔符。用整条路径的 value 拼接（而非节点自身自增 id），
 * 使同一 value 在不同分支下天然生成不同 key（对齐 Semi `VALUE_SPLIT` 思路）。 */
const VALUE_SPLIT = '_LOTUS_CASCADER_SPLIT_';

export function joinValuePath(valuePath: Array<string | number>): string {
  return valuePath.map(String).join(VALUE_SPLIT);
}

/** Cascader 专用 entity：与 Tree 的 `KeyEntity` 摊平索引结构同构（key/level/
 * data/parent/children），额外持有 `valuePath`（原始 value 路径，用于对外
 * value 数组）。key 用路径拼接生成而非节点自身 key 字段，`data` 字段类型也
 * 不同（`CascaderNodeData` vs `TreeNodeData`），两者类型不完全一致，
 * TypeScript 不允许直接把 `CascaderEntities` 传给 Tree 那三个标注为
 * `KeyEntities` 的遍历函数，故祖先链/后代链/兄弟链查找在本文件内重写一份
 * （逻辑与 Tree 的 `findAncestorKeys`/`findDescendantKeys`/`findSiblingKeys`
 * 完全一致，只是换了类型）。三态级联算法本身（`calcCheckedKeysForChecked`/
 * `calcCheckedKeysForUnchecked`）不重复实现，在 foundation.ts 里直接从
 * `check-cascade.ts` import 并对 entities 做一次 `as unknown as KeyEntities`
 * 类型转换调用——安全，因为这两个函数运行时只读 `key`/`parent`/`children`
 * 字段（内部又通过 findAncestorKeys 等三个函数间接访问，同样不碰 `.data`），
 * 从未访问 `.data`，`CascaderEntity`/`KeyEntity` 在这三个字段上结构完全一致。 */
export interface CascaderEntity {
  key: string;
  level: number;
  data: CascaderNodeData;
  parent: CascaderEntity | null;
  children: CascaderEntity[];
  valuePath: Array<string | number>;
}

export type CascaderEntities = Record<string, CascaderEntity>;

/** 摊平嵌套 CascaderData 为 key(路径拼接) -> CascaderEntity 索引表。与 Tree 的
 * `buildKeyEntities` 同构，区别只在 key 生成方式（路径拼接而非节点自身 key）。 */
export function buildCascaderEntities(data: CascaderNodeData[]): CascaderEntities {
  const entities: CascaderEntities = {};

  function walk(nodes: CascaderNodeData[], parent: CascaderEntity | null, level: number, parentValuePath: Array<string | number>): CascaderEntity[] {
    return nodes.map((node) => {
      const valuePath = [...parentValuePath, node.value];
      const key = joinValuePath(valuePath);
      const entity: CascaderEntity = { key, level, data: node, parent, children: [], valuePath };
      entities[key] = entity;
      if (node.children?.length) {
        entity.children = walk(node.children, entity, level + 1, valuePath);
      }
      return entity;
    });
  }

  walk(data, null, 0, []);
  return entities;
}

export function isLeafEntity(entity: CascaderEntity): boolean {
  return entity.data.isLeaf ?? entity.children.length === 0;
}

/** 由 valuePath 找到对应 key；找不到（路径不完整匹配任何节点）返回 null。 */
export function findKeyByValuePath(valuePath: Array<string | number>, entities: CascaderEntities): string | null {
  const key = joinValuePath(valuePath);
  return entities[key] ? key : null;
}

/** 找一批 key 的全部祖先 key（不含自己，除非 self=true）。逻辑与 Tree 的
 * `findAncestorKeys` 完全一致，见 CascaderEntity 类型说明。 */
export function findAncestorKeys(keys: Iterable<string>, entities: CascaderEntities, self = true): string[] {
  const result = new Set<string>();
  for (const key of keys) {
    if (self) result.add(key);
    let node = entities[key]?.parent ?? null;
    while (node) {
      result.add(node.key);
      node = node.parent;
    }
  }
  return [...result];
}

/** 找一个节点的路径完整数据数组（从根到自身，含自身），用于展示回填文本/
 * 搜索结果打平展示的 pathData。 */
export function getPathData(key: string, entities: CascaderEntities): CascaderNodeData[] {
  const entity = entities[key];
  if (!entity) return [];
  const path: CascaderNodeData[] = [];
  let node: CascaderEntity | null = entity;
  while (node) {
    path.unshift(node.data);
    node = node.parent;
  }
  return path;
}

/** 每一级路径对应的兄弟节点列表（多列面板的"列"数据）。`activeKeys` 是当前
 * 激活路径上所有 key 的集合（对齐 Semi 语义：不是"哪些列展开"，而是"当前
 * 选中/悬停到了哪一条路径"，列的展开效果由此路径派生）。
 *
 * 第 0 列固定是根节点列表；此后每一列是"上一列里被 activeKeys 命中的那个
 * 节点"的 children，直到某一级节点不在 activeKeys 中或已是叶子为止。 */
export function computeColumns(rootData: CascaderNodeData[], activeKeys: Set<string>, entities: CascaderEntities): CascaderEntity[][] {
  const columns: CascaderEntity[][] = [];
  let currentLevelKeys = rootData.map((node) => entities[joinValuePath([node.value])]).filter((e): e is CascaderEntity => !!e);
  columns.push(currentLevelKeys);

  while (true) {
    const activeInLevel = currentLevelKeys.find((e) => activeKeys.has(e.key));
    if (!activeInLevel || activeInLevel.children.length === 0) break;
    columns.push(activeInLevel.children);
    currentLevelKeys = activeInLevel.children;
  }

  return columns;
}
