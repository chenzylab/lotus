/**
 * Badge 是纯展示型组件，没有内部状态机，Foundation 层只承载
 * "count 如何格式化 / 该不该显示 / 是不是自定义内容" 这几条与
 * Ripple 渲染无关的纯函数判定逻辑，供组件层直接调用。
 */

export function shouldShowBadge(count: unknown, dot: boolean): boolean {
  if (dot) return true;
  return count !== null && count !== undefined;
}

export function isCustomContent(count: unknown): boolean {
  return count !== null && count !== undefined && typeof count !== 'number' && typeof count !== 'string';
}

export function formatCount(count: unknown, overflowCount?: number): string {
  if (typeof count === 'number') {
    if (typeof overflowCount === 'number' && overflowCount < count) {
      return `${overflowCount}+`;
    }
    return String(count);
  }
  if (typeof count === 'string') return count;
  return '';
}
