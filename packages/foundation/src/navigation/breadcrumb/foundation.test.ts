import { describe, it, expect } from 'vitest';
import { BreadcrumbFoundation, type NormalizedRoute } from './foundation.js';

describe('BreadcrumbFoundation.normalizeRoutes', () => {
  it('字符串路由转换为 { name, origin } 对象', () => {
    const result = BreadcrumbFoundation.normalizeRoutes(['首页', '详情页']);
    expect(result).toEqual([
      { name: '首页', origin: '首页' },
      { name: '详情页', origin: '详情页' },
    ]);
  });

  it('对象路由保留 name/path/href/icon 并附带 origin 引用', () => {
    const route = { path: '/', href: '/', name: 'home', icon: 'icon-home' };
    const result = BreadcrumbFoundation.normalizeRoutes([route]);
    expect(result).toEqual([{ name: 'home', path: '/', href: '/', icon: 'icon-home', origin: route }]);
  });

  it('对象路由未传 name 时归一化为空字符串（不假设 fallback 到 path）', () => {
    const route = { path: '/detail' };
    const result = BreadcrumbFoundation.normalizeRoutes([route]);
    expect(result[0]!.name).toBe('');
  });
});

function routesOf(count: number): NormalizedRoute[] {
  return Array.from({ length: count }, (_, i) => ({ name: `level-${i}`, origin: `level-${i}` }));
}

describe('BreadcrumbFoundation.computeCollapse', () => {
  it('层级数不超过 maxItemCount 时不折叠', () => {
    const { collapsedRange } = BreadcrumbFoundation.computeCollapse(routesOf(4), 4, true, false);
    expect(collapsedRange).toBeNull();
  });

  it('层级数超过 maxItemCount 时折叠中间区间，保留首项与尾部 maxItemCount-1 项', () => {
    const { collapsedRange } = BreadcrumbFoundation.computeCollapse(routesOf(7), 4, true, false);
    // 7 项，maxItemCount=4：保留下标0 + 尾部3项(下标4,5,6)，折叠区间 [1, 3]（下标1,2,3被折叠）
    expect(collapsedRange).toEqual([1, 3]);
  });

  it('autoCollapse=false 时不折叠，即使超出 maxItemCount', () => {
    const { collapsedRange } = BreadcrumbFoundation.computeCollapse(routesOf(7), 4, false, false);
    expect(collapsedRange).toBeNull();
  });

  it('expanded=true（已点击展开）时不折叠', () => {
    const { collapsedRange } = BreadcrumbFoundation.computeCollapse(routesOf(7), 4, true, true);
    expect(collapsedRange).toBeNull();
  });

  it('maxItemCount < 2 时不折叠（首项+尾项至少需要 2 个保留位）', () => {
    const { collapsedRange } = BreadcrumbFoundation.computeCollapse(routesOf(7), 1, true, false);
    expect(collapsedRange).toBeNull();
  });
});

describe('BreadcrumbFoundation.buildDisplayItems', () => {
  it('不折叠时（collapsedRange=null）原样按顺序输出全部路由项', () => {
    const routes = routesOf(4);
    const items = BreadcrumbFoundation.buildDisplayItems(routes, null, []);
    expect(items.map((it) => (it.type === 'route' ? it.route.name : '***'))).toEqual([
      'level-0', 'level-1', 'level-2', 'level-3',
    ]);
    expect(items.every((it) => it.type === 'route')).toBe(true);
  });

  it('折叠时在折叠起点插入一个 more 占位符，中间项被跳过，顺序保持首项在前、尾项在后', () => {
    const routes = routesOf(7);
    const { collapsedRange } = BreadcrumbFoundation.computeCollapse(routes, 4, true, false);
    const restRoutes = routes.slice(collapsedRange![0], collapsedRange![1] + 1);
    const items = BreadcrumbFoundation.buildDisplayItems(routes, collapsedRange, restRoutes);

    expect(items.map((it) => (it.type === 'more' ? '***' : it.route.name))).toEqual([
      'level-0', '***', 'level-4', 'level-5', 'level-6',
    ]);
  });

  it('more 占位符携带被折叠的 restRoutes，供 renderMore/popover 展示', () => {
    const routes = routesOf(7);
    const { collapsedRange } = BreadcrumbFoundation.computeCollapse(routes, 4, true, false);
    const restRoutes = routes.slice(collapsedRange![0], collapsedRange![1] + 1);
    const items = BreadcrumbFoundation.buildDisplayItems(routes, collapsedRange, restRoutes);

    const more = items.find((it) => it.type === 'more');
    expect(more?.type === 'more' && more.restRoutes.map((r) => r.name)).toEqual(['level-1', 'level-2', 'level-3']);
  });

  it('展开态（collapsedRange=null）时不产生 more 占位符，全部原始项按序输出，即使层级很多', () => {
    const routes = routesOf(7);
    const items = BreadcrumbFoundation.buildDisplayItems(routes, null, []);
    expect(items.map((it) => (it.type === 'more' ? '***' : it.route.name))).toEqual([
      'level-0', 'level-1', 'level-2', 'level-3', 'level-4', 'level-5', 'level-6',
    ]);
  });

  it('isLast 只标记最后一个路由项，用于判断是否渲染分隔符/aria-current', () => {
    const routes = routesOf(3);
    const items = BreadcrumbFoundation.buildDisplayItems(routes, null, []);
    const flags = items.map((it) => (it.type === 'route' ? it.isLast : false));
    expect(flags).toEqual([false, false, true]);
  });

  it('传入 activeIndex 时按显式索引标记当前页，不再默认最后一项', () => {
    const routes = routesOf(3);
    const items = BreadcrumbFoundation.buildDisplayItems(routes, null, [], 1);
    const flags = items.map((it) => (it.type === 'route' ? it.isLast : false));
    expect(flags).toEqual([false, true, false]);
  });
});

describe('BreadcrumbFoundation.toggleExpand', () => {
  it('切换 collapseExpanded 状态', () => {
    let state = { collapseExpanded: false };
    const adapter = {
      getState: () => state,
      setState: (patch: Partial<typeof state>) => { state = { ...state, ...patch }; },
    };
    const foundation = new BreadcrumbFoundation(adapter);

    foundation.toggleExpand();
    expect(state.collapseExpanded).toBe(true);

    foundation.toggleExpand();
    expect(state.collapseExpanded).toBe(false);
  });
});
