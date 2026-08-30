import type { RenderRouteOptions } from '@ripple-ts/vite-plugin';

// 用 plain object 字面量代替 `new RenderRoute(...)`——不能从 @ripple-ts/vite-plugin
// 值 import RenderRoute 类。这个包的主入口 src/index.js 顶层混合了完整的服务端逻辑
// （import 了 ./server/router.js、./server/middleware.js 等），dev 模式下 Vite 用
// 原生 ESM 不做 tree-shaking，任何对这个包的值 import（哪怕只是从它的 re-export 里
// 拿一个简单的数据类）都会导致浏览器完整加载执行这整条服务端模块图。这条 import 链
// 通过 apps/docs/ripple.config.ts 被客户端 hydrate 入口脚本引用，实测会导致 Ripple
// 的事件委托系统（handle_root_events/delegate）没有被页面主运行时正确初始化——
// 所有 onClick 交互（Switch、Button、InputNumber 步进器等）完全失效，且没有任何
// 报错，非常隐蔽。这是继 defineConfig 值 import 触发 process.platform 崩溃（踩坑
// #9）之后，同一类"上游包主入口混合服务端代码"问题的第二个独立实例。
//
// RenderRoute 类本身只是把 options 字段原样赋值到实例上（含 type: 'render' 常量
// 字段和 before 的默认值 []），服务端渲染逻辑只读取 type/path/entry/layout/before
// 这几个字段，plain object 与真正的类实例在运行时完全等价。
export interface RenderRouteLike {
  readonly type: 'render';
  path: string;
  entry: RenderRouteOptions['entry'];
  layout?: string;
  before: never[];
}

function renderRoute(options: { path: string; entry: string; layout?: string }): RenderRouteLike {
  return { type: 'render', path: options.path, entry: options.entry, layout: options.layout, before: [] };
}

export const routes = [
  renderRoute({ path: '/', entry: '/src/pages/index.tsrx' }),
  renderRoute({ path: '/basic/button', entry: '/src/pages/basic/button.tsrx' }),
  renderRoute({ path: '/basic/divider', entry: '/src/pages/basic/divider.tsrx' }),
  renderRoute({ path: '/basic/space', entry: '/src/pages/basic/space.tsrx' }),
  renderRoute({ path: '/basic/grid', entry: '/src/pages/basic/grid.tsrx' }),
  renderRoute({ path: '/basic/layout', entry: '/src/pages/basic/layout.tsrx' }),
  renderRoute({ path: '/basic/typography', entry: '/src/pages/basic/typography.tsrx' }),
  renderRoute({ path: '/basic/icon-button', entry: '/src/pages/basic/icon-button.tsrx' }),
  renderRoute({ path: '/basic/float-button', entry: '/src/pages/basic/float-button.tsrx' }),
  renderRoute({ path: '/basic/resizable', entry: '/src/pages/basic/resizable.tsrx' }),
  renderRoute({ path: '/basic/drag-move', entry: '/src/pages/basic/drag-move.tsrx' }),
  renderRoute({ path: '/basic/hotkeys', entry: '/src/pages/basic/hotkeys.tsrx' }),
  renderRoute({ path: '/input/input', entry: '/src/pages/input/input.tsrx' }),
  renderRoute({ path: '/input/switch', entry: '/src/pages/input/switch.tsrx' }),
  renderRoute({ path: '/input/checkbox', entry: '/src/pages/input/checkbox.tsrx' }),
  renderRoute({ path: '/input/radio', entry: '/src/pages/input/radio.tsrx' }),
  renderRoute({ path: '/input/input-number', entry: '/src/pages/input/input-number.tsrx' }),
  renderRoute({ path: '/input/select', entry: '/src/pages/input/select.tsrx' }),
  renderRoute({ path: '/input/form', entry: '/src/pages/input/form.tsrx' }),
  renderRoute({ path: '/navigation/breadcrumb', entry: '/src/pages/navigation/breadcrumb.tsrx' }),
  renderRoute({ path: '/navigation/anchor', entry: '/src/pages/navigation/anchor.tsrx' }),
  renderRoute({ path: '/navigation/back-top', entry: '/src/pages/navigation/back-top.tsrx' }),
  renderRoute({ path: '/navigation/pagination', entry: '/src/pages/navigation/pagination.tsrx' }),
  renderRoute({ path: '/navigation/steps', entry: '/src/pages/navigation/steps.tsrx' }),
  renderRoute({ path: '/navigation/tree', entry: '/src/pages/navigation/tree.tsrx' }),
  renderRoute({ path: '/show/tag', entry: '/src/pages/show/tag.tsrx' }),
  renderRoute({ path: '/show/avatar', entry: '/src/pages/show/avatar.tsrx' }),
  renderRoute({ path: '/show/tooltip', entry: '/src/pages/show/tooltip.tsrx' }),
  renderRoute({ path: '/show/popover', entry: '/src/pages/show/popover.tsrx' }),
  renderRoute({ path: '/show/dropdown', entry: '/src/pages/show/dropdown.tsrx' }),
  renderRoute({ path: '/feedback/skeleton', entry: '/src/pages/feedback/skeleton.tsrx' }),
  renderRoute({ path: '/feedback/banner', entry: '/src/pages/feedback/banner.tsrx' }),
  renderRoute({ path: '/feedback/notification', entry: '/src/pages/feedback/notification.tsrx' }),
  renderRoute({ path: '/feedback/popconfirm', entry: '/src/pages/feedback/popconfirm.tsrx' }),
  renderRoute({ path: '/feedback/progress', entry: '/src/pages/feedback/progress.tsrx' }),
  renderRoute({ path: '/feedback/spin', entry: '/src/pages/feedback/spin.tsrx' }),
  renderRoute({ path: '/feedback/toast', entry: '/src/pages/feedback/toast.tsrx' }),
  renderRoute({ path: '/navigation/navigation', entry: '/src/pages/navigation/navigation.tsrx' }),
  renderRoute({ path: '/navigation/tabs', entry: '/src/pages/navigation/tabs.tsrx' }),
];
