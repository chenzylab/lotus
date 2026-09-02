import { Foundation, type Adapter } from '../../base/adapter.js';

export interface BreadcrumbRoute {
  name?: string;
  path?: string;
  href?: string;
  icon?: unknown;
}

/** 归一化后的路由项：字符串简写统一转换为对象，附带原始输入引用。 */
export interface NormalizedRoute {
  name: string;
  path?: string;
  href?: string;
  icon?: unknown;
  origin: BreadcrumbRoute | string;
}

export interface BreadcrumbState {
  /** 折叠区域是否已展开（点击省略号后展开显示全部级别）。 */
  collapseExpanded: boolean;
}

/**
 * Breadcrumb 的路由归一化 + 折叠区间计算。设计参考 Semi BreadcrumbFoundation.genRoutes
 * 与 UI 层 handleCollapse 的 splice 折叠思路（保留首项 + 尾部 maxItemCount-1 项，
 * 中间替换为省略号），重新实现为纯函数，不搬运代码。
 */
export class BreadcrumbFoundation extends Foundation<BreadcrumbState> {
  static normalizeRoutes(routes: Array<BreadcrumbRoute | string>): NormalizedRoute[] {
    return routes.map((route) => {
      if (typeof route === 'string') {
        return { name: route, origin: route };
      }
      return { name: route.name ?? '', path: route.path, href: route.href, icon: route.icon, origin: route };
    });
  }

  /**
   * 计算折叠后的可见结构：`autoCollapse` 关闭、层级数不超过 `maxItemCount`、
   * 或折叠区域已展开时，返回全部路由（`collapsedRange` 为 null，不折叠）。
   * 否则返回首项 + 折叠区间（省略号代表的中间段）+ 尾部保留项。
   */
  static computeCollapse(
    routes: NormalizedRoute[],
    maxItemCount: number,
    autoCollapse: boolean,
    expanded: boolean,
  ): { collapsedRange: [number, number] | null } {
    const shouldCollapse = autoCollapse && !expanded && routes.length > maxItemCount && maxItemCount >= 2;
    if (!shouldCollapse) return { collapsedRange: null };

    // 保留下标 0（首项）与最后 maxItemCount-1 项，折叠区间为 [1, length - maxItemCount]（闭区间，下标）。
    const collapseEnd = routes.length - maxItemCount;
    return { collapsedRange: [1, collapseEnd] };
  }

  /**
   * 把「路由数组 + 折叠区间」预先摊平成一份可直接单层 `@for` 渲染的展示项列表——
   * 每一项要么是普通路由（`type: 'route'`），要么是省略号占位符（`type: 'more'`，
   * 代表被折叠的中间段）。这样模板侧只需要一个不含内部条件跳过的 `@for` 循环，
   * 避免在循环体内再嵌套 `@if` 部分跳过渲染导致的 keyed-diff 顺序错乱
   * （2026-08-13 真机实测发现：`@for` 循环体内用 `@if` 跳过某些项不渲染，
   * 折叠态切换为展开态时，曾经渲染过的项与新增项的相对顺序错乱，
   * 详见 specs/cross-cutting/foundation-adapter-pattern.md 踩坑记录）。
   */
  /** `activeIndex` 未传时按 Semi 默认语义——最后一项视为"当前页"
   * （`aria-current="page"` + 高亮样式）；传入后改为该显式索引。 */
  static buildDisplayItems(
    routes: NormalizedRoute[],
    collapsedRange: [number, number] | null,
    restRoutes: NormalizedRoute[],
    activeIndex?: number,
  ): Array<{ type: 'route'; route: NormalizedRoute; index: number; isLast: boolean } | { type: 'more'; restRoutes: NormalizedRoute[] }> {
    const items: Array<{ type: 'route'; route: NormalizedRoute; index: number; isLast: boolean } | { type: 'more'; restRoutes: NormalizedRoute[] }> = [];
    const activeAt = activeIndex ?? routes.length - 1;
    routes.forEach((route, index) => {
      if (collapsedRange && index === collapsedRange[0]) {
        items.push({ type: 'more', restRoutes });
      }
      if (collapsedRange && index >= collapsedRange[0] && index <= collapsedRange[1]) {
        return;
      }
      items.push({ type: 'route', route, index, isLast: index === activeAt });
    });
    return items;
  }

  toggleExpand(): void {
    const { collapseExpanded } = this.getState();
    this.setState({ collapseExpanded: !collapseExpanded });
  }
}
