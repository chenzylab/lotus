import type { RippleConfigOptions } from '@ripple-ts/vite-plugin';
import { serve, runtime } from '@ripple-ts/adapter-node';

import { routes } from './src/routes';

// 本地恒等函数代替 @ripple-ts/vite-plugin 的 defineConfig——该函数本身只是
// `(options) => options`（见 vite-plugin/src/index.js:1208），但从
// @ripple-ts/vite-plugin 值 import 任何具名导出都会拉入整个模块的顶层代码，
// 其中包含一行未加保护的 `const IS_WINDOWS = process.platform === 'win32'`
// （src/index.js:48）。Ripple 的客户端 hydrate 入口代码生成器会把这份
// ripple.config.ts 整体打包进浏览器 bundle，浏览器执行到这行时抛
// `ReferenceError: process is not defined`，中断整个客户端 hydrate 脚本的
// 顶层执行——表现为页面能正常渲染出 HTML，但所有交互（onClick/onInput/
// track() 状态更新）全部失效，且异常被吞掉不会显式报错，非常隐蔽。
// 详见 specs/cross-cutting/foundation-adapter-pattern.md 踩坑 #9。
// `import type` 不产生任何运行时代码，不会触发这个问题。
function defineConfig(options: RippleConfigOptions): RippleConfigOptions {
  return options;
}

export default defineConfig({
  build: {
    minify: false,
    outDir: 'dist',
    target: 'es2022',
  },
  adapter: { serve, runtime },
  router: { routes },
});
