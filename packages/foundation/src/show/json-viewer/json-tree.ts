/**
 * JsonViewer 核心数据结构：把任意 JSON 值转换成可展开/折叠的树形节点。
 *
 * lotus 走"结构化树查看器"定位而非 Semi/chenzy.design 的"克隆 VS Code
 * 文本编辑器内核"路线（`@douyinfe/semi-json-viewer-core` 是私有 npm 包、
 * Plus 付费组件，与 lotus 现有的轻量自研风格不符，调研已核实不移植）。
 *
 * 展开/折叠状态管理复用 Tree 组件同款设计思路（path 当 key + `Set<string>`
 * 管理展开集合 + 摊平成一维可见列表供渲染），但 JSON 值没有 Tree 那种显式
 * 声明的 `TreeNodeData.key`，节点标识改用从根出发拼接的路径字符串
 * （如 `root.a[0].b`），路径本身就是稳定唯一标识，不需要额外的 KeyEntities
 * 索引表。
 */

export type JsonValueType = 'object' | 'array' | 'string' | 'number' | 'boolean' | 'null';

export interface JsonNode {
  /** 节点的稳定路径标识，如 'root'、'root.a'、'root.a[0]'。 */
  path: string;
  /** 在父对象里的 key（对象成员）或数组下标转字符串（数组元素）；根节点为 null。 */
  key: string | null;
  /** 是对象成员还是数组元素；根节点为 null。 */
  parentKind: 'object' | 'array' | null;
  type: JsonValueType;
  /** 叶子值（string/number/boolean/null）的实际值；object/array 为 undefined。 */
  value: unknown;
  /** object/array 的子节点；叶子节点为空数组。 */
  children: JsonNode[];
  level: number;
}

export function getJsonValueType(value: unknown): JsonValueType {
  if (value === null) return 'null';
  if (Array.isArray(value)) return 'array';
  const t = typeof value;
  if (t === 'object') return 'object';
  if (t === 'string' || t === 'number' || t === 'boolean') return t;
  return 'null';
}

/** 把任意 JSON 值（对象/数组/原始值）递归构建成 JsonNode 树，根路径固定为 'root'。 */
export function buildJsonTree(value: unknown, path = 'root', key: string | null = null, parentKind: JsonNode['parentKind'] = null, level = 0): JsonNode {
  const type = getJsonValueType(value);

  if (type === 'object') {
    const entries = Object.entries(value as Record<string, unknown>);
    return {
      path,
      key,
      parentKind,
      type,
      value: undefined,
      level,
      children: entries.map(([k, v]) => buildJsonTree(v, `${path}.${k}`, k, 'object', level + 1)),
    };
  }

  if (type === 'array') {
    const items = value as unknown[];
    return {
      path,
      key,
      parentKind,
      type,
      value: undefined,
      level,
      children: items.map((v, i) => buildJsonTree(v, `${path}[${i}]`, String(i), 'array', level + 1)),
    };
  }

  return { path, key, parentKind, type, value, level, children: [] };
}

/** 把字符串或已解析的值统一转换为 JsonNode 树；字符串解析失败时返回 null。 */
export function parseToJsonTree(input: unknown): JsonNode | null {
  if (typeof input !== 'string') return buildJsonTree(input);
  try {
    return buildJsonTree(JSON.parse(input));
  } catch {
    return null;
  }
}

/** 计算默认展开集合：展开 level < depth 的全部容器节点路径（depth=0 时全部折叠）。 */
export function calcDefaultExpandedPaths(root: JsonNode, depth: number): Set<string> {
  const result = new Set<string>();
  function walk(node: JsonNode) {
    if (node.children.length === 0) return;
    if (node.level < depth) {
      result.add(node.path);
      for (const child of node.children) walk(child);
    }
  }
  walk(root);
  return result;
}

/** 展开树上全部容器节点的路径（expandAll 用）。 */
export function calcAllExpandedPaths(root: JsonNode): Set<string> {
  const result = new Set<string>();
  function walk(node: JsonNode) {
    if (node.children.length === 0) return;
    result.add(node.path);
    for (const child of node.children) walk(child);
  }
  walk(root);
  return result;
}

/** 切换单个路径的展开状态，返回新集合（不修改传入集合）。 */
export function toggleExpandedPath(path: string, expandedPaths: Set<string>): Set<string> {
  const next = new Set(expandedPaths);
  if (next.has(path)) {
    next.delete(path);
  } else {
    next.add(path);
  }
  return next;
}

/**
 * 用一个新的叶子值原地替换树上某路径的节点值（可编辑模式下叶子节点提交编辑用），
 * 返回全新的根节点（不修改原树，其余分支节点复用引用）。找不到路径时原样返回根。
 */
export function replaceNodeValue(root: JsonNode, path: string, nextValue: unknown): JsonNode {
  if (root.path === path) {
    return { ...root, type: getJsonValueType(nextValue), value: nextValue, children: [] };
  }
  if (root.children.length === 0) return root;
  let changed = false;
  const children = root.children.map((child) => {
    if (path === child.path || path.startsWith(`${child.path}.`) || path.startsWith(`${child.path}[`)) {
      const next = replaceNodeValue(child, path, nextValue);
      if (next !== child) changed = true;
      return next;
    }
    return child;
  });
  return changed ? { ...root, children } : root;
}

/** 把 JsonNode 树还原成普通 JS 值（可编辑模式下向外抛 onChange 用）。 */
export function jsonTreeToValue(node: JsonNode): unknown {
  if (node.type === 'object') {
    const out: Record<string, unknown> = {};
    for (const child of node.children) out[child.key as string] = jsonTreeToValue(child);
    return out;
  }
  if (node.type === 'array') {
    return node.children.map((child) => jsonTreeToValue(child));
  }
  return node.value;
}
