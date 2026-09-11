export interface TreeNodeData {
  /** 传 keyMaps.key 映射到其它字段名时本字段可以不存在，仅索引签名兜底
   *  仍要求它「可以不填」——标准场景（未传 keyMaps）下这是必填约定，
   *  但类型层面放宽为可选，兼容 keyMaps 场景下真实字段名不同的数据源。 */
  key?: string;
  label?: any;
  value?: string;
  icon?: any;
  disabled?: boolean;
  isLeaf?: boolean;
  children?: TreeNodeData[];
  [extra: string]: unknown;
}

/**
 * 自定义字段名映射（对齐 Semi Tree/Cascader `keyMaps`），用于适配字段名不是
 * `key`/`label`/`value`/`children`/`disabled`/`isLeaf` 的数据源。未提供某个
 * 字段的映射时回退标准字段名。
 */
export interface KeyMapProps {
  key?: string;
  label?: string;
  value?: string;
  disabled?: string;
  children?: string;
  isLeaf?: string;
  icon?: string;
}

/** 按 keyMaps 读取节点的 key 字段；未配置映射时回退标准字段名 `key`。 */
export function getNodeKey(node: TreeNodeData, keyMaps?: KeyMapProps): string {
  return node[keyMaps?.key ?? 'key'] as string;
}

/** 按 keyMaps 读取节点的 label 字段；未配置映射时回退标准字段名 `label`。 */
export function getNodeLabel(node: TreeNodeData, keyMaps?: KeyMapProps): unknown {
  return node[keyMaps?.label ?? 'label'];
}

/** 按 keyMaps 读取节点的 value 字段；未配置映射时回退标准字段名 `value`。 */
export function getNodeValue(node: TreeNodeData, keyMaps?: KeyMapProps): string | undefined {
  return node[keyMaps?.value ?? 'value'] as string | undefined;
}

/** 按 keyMaps 读取节点的 children 字段；未配置映射时回退标准字段名 `children`。 */
export function getNodeChildren(node: TreeNodeData, keyMaps?: KeyMapProps): TreeNodeData[] | undefined {
  return node[keyMaps?.children ?? 'children'] as TreeNodeData[] | undefined;
}

/** 按 keyMaps 读取节点的 disabled 字段；未配置映射时回退标准字段名 `disabled`。 */
export function getNodeDisabled(node: TreeNodeData, keyMaps?: KeyMapProps): boolean | undefined {
  return node[keyMaps?.disabled ?? 'disabled'] as boolean | undefined;
}

/** 按 keyMaps 读取节点的 isLeaf 字段；未配置映射时回退标准字段名 `isLeaf`。 */
export function getNodeIsLeaf(node: TreeNodeData, keyMaps?: KeyMapProps): boolean | undefined {
  return node[keyMaps?.isLeaf ?? 'isLeaf'] as boolean | undefined;
}

/** 按 keyMaps 读取节点的 icon 字段；未配置映射时回退标准字段名 `icon`。 */
export function getNodeIcon(node: TreeNodeData, keyMaps?: KeyMapProps): unknown {
  return node[keyMaps?.icon ?? 'icon'];
}

/** 构建后的节点索引条目：持有对父/子条目的引用，用于三态级联/展开祖先链计算。 */
export interface KeyEntity {
  key: string;
  level: number;
  data: TreeNodeData;
  parent: KeyEntity | null;
  children: KeyEntity[];
}

export type KeyEntities = Record<string, KeyEntity>;

/**
 * 把嵌套 treeData 摊平成 key -> KeyEntity 的索引表，每个条目持有 parent/
 * children 引用（对齐 Semi 的 convertDataToEntities），后续三态级联、
 * 祖先链查找都基于这份索引做 O(深度) 的遍历，不需要每次重新扫描原始树。
 */
export function buildKeyEntities(treeData: TreeNodeData[], keyMaps?: KeyMapProps): KeyEntities {
  const entities: KeyEntities = {};

  function walk(nodes: TreeNodeData[], parent: KeyEntity | null, level: number): KeyEntity[] {
    return nodes.map((node) => {
      const key = getNodeKey(node, keyMaps);
      const entity: KeyEntity = { key, level, data: node, parent, children: [] };
      entities[key] = entity;
      const children = getNodeChildren(node, keyMaps);
      if (children?.length) {
        entity.children = walk(children, entity, level + 1);
      }
      return entity;
    });
  }

  walk(treeData, null, 0);
  return entities;
}

export interface FlatTreeNode {
  key: string;
  label: any;
  value?: string;
  icon?: any;
  disabled: boolean;
  isLeaf: boolean;
  level: number;
  hasChildren: boolean;
  data: TreeNodeData;
}

/**
 * 摊平树形数据成一维数组，只包含"展开路径上可见"的节点——未展开分支的
 * 子孙节点完全不进入结果数组，渲染层拿到的就是最终应该显示的完整列表，
 * 不需要在 @for 循环体内再做可见性判断（对齐 Breadcrumb 的踩坑 #13
 * 修复范式：可见性过滤在 Foundation 层的数据生成阶段完成，不是渲染阶段）。
 * `filteredShownKeys` 非空时只保留白名单内的 key（用于搜索 showFilteredOnly）。
 */
export function flattenTreeData(
  treeData: TreeNodeData[],
  expandedKeys: Set<string>,
  filteredShownKeys?: Set<string> | null,
  keyMaps?: KeyMapProps,
): FlatTreeNode[] {
  const result: FlatTreeNode[] = [];

  function walk(nodes: TreeNodeData[], level: number) {
    for (const node of nodes) {
      const key = getNodeKey(node, keyMaps);
      const children = getNodeChildren(node, keyMaps);
      const hasChildren = !!children?.length;
      const isLeaf = getNodeIsLeaf(node, keyMaps) ?? !hasChildren;
      const visible = !filteredShownKeys || filteredShownKeys.has(key);

      if (visible) {
        result.push({
          key,
          label: getNodeLabel(node, keyMaps),
          value: getNodeValue(node, keyMaps),
          icon: getNodeIcon(node, keyMaps),
          disabled: getNodeDisabled(node, keyMaps) ?? false,
          isLeaf,
          level,
          hasChildren,
          data: node,
        });
      }

      if (expandedKeys.has(key) && hasChildren) {
        walk(children!, level + 1);
      }
    }
  }

  walk(treeData, 0);
  return result;
}

/** 找一批 key 的全部祖先 key（不含自己，除非 self=true）。 */
export function findAncestorKeys(keys: Iterable<string>, entities: KeyEntities, self = true): string[] {
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

/** 找一批 key 的全部后代 key（含自己，除非 self=false）。 */
export function findDescendantKeys(keys: Iterable<string>, entities: KeyEntities, self = true): string[] {
  const result = new Set<string>();
  function collect(entity: KeyEntity) {
    for (const child of entity.children) {
      result.add(child.key);
      collect(child);
    }
  }
  for (const key of keys) {
    if (self) result.add(key);
    const entity = entities[key];
    if (entity) collect(entity);
  }
  return [...result];
}

/** 找一个节点的全部兄弟 key（含自己，除非 self=false）。 */
export function findSiblingKeys(key: string, entities: KeyEntities, self = true): string[] {
  const entity = entities[key];
  if (!entity) return self ? [key] : [];
  const siblings = entity.parent ? entity.parent.children : Object.values(entities).filter((e) => !e.parent);
  return siblings.filter((s) => self || s.key !== key).map((s) => s.key);
}
