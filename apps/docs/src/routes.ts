import { RenderRoute } from '@ripple-ts/vite-plugin';

export const routes = [
  new RenderRoute({ path: '/', entry: '/src/pages/index.tsrx' }),
  new RenderRoute({ path: '/basic/button', entry: '/src/pages/basic/button.tsrx' }),
  new RenderRoute({ path: '/basic/divider', entry: '/src/pages/basic/divider.tsrx' }),
  new RenderRoute({ path: '/basic/space', entry: '/src/pages/basic/space.tsrx' }),
  new RenderRoute({ path: '/basic/grid', entry: '/src/pages/basic/grid.tsrx' }),
  new RenderRoute({ path: '/basic/layout', entry: '/src/pages/basic/layout.tsrx' }),
  new RenderRoute({ path: '/basic/typography', entry: '/src/pages/basic/typography.tsrx' }),
  new RenderRoute({ path: '/input/input', entry: '/src/pages/input/input.tsrx' }),
  new RenderRoute({ path: '/input/switch', entry: '/src/pages/input/switch.tsrx' }),
  new RenderRoute({ path: '/navigation/breadcrumb', entry: '/src/pages/navigation/breadcrumb.tsrx' }),
  new RenderRoute({ path: '/show/tag', entry: '/src/pages/show/tag.tsrx' }),
  new RenderRoute({ path: '/show/avatar', entry: '/src/pages/show/avatar.tsrx' }),
  new RenderRoute({ path: '/show/tooltip', entry: '/src/pages/show/tooltip.tsrx' }),
  new RenderRoute({ path: '/show/popover', entry: '/src/pages/show/popover.tsrx' }),
  new RenderRoute({ path: '/show/dropdown', entry: '/src/pages/show/dropdown.tsrx' }),
  new RenderRoute({ path: '/feedback/skeleton', entry: '/src/pages/feedback/skeleton.tsrx' }),
  new RenderRoute({ path: '/navigation/navigation', entry: '/src/pages/navigation/navigation.tsrx' }),
  new RenderRoute({ path: '/navigation/tabs', entry: '/src/pages/navigation/tabs.tsrx' }),
];
