import { ripple } from '@ripple-ts/vite-plugin';
import { defineConfig } from 'vite';

export default defineConfig({
  build: {
    minify: false,
  },
  // dev 模式噪音抑制（不解决根本问题，见下方 CRITICAL 说明）：exclude 掉
  // @ripple-ts/vite-plugin 能消除 dev 模式下 esbuild 依赖预构建误扫描它产生的
  // "process is not defined" 噪音，但对生产构建完全无效——optimizeDeps 只影响
  // dev 依赖预构建，不影响 rollup/rolldown 打包结果。
  //
  // CRITICAL：这不是"已解决"，是两个独立问题里解决了较不重要的那个。真正影响功能的
  // 那个问题在生产构建下依然存在且未修复：apps/docs/ripple.config.ts import 了
  // @ripple-ts/vite-plugin 的 defineConfig，导致整个 ripple.config.ts（含
  // @ripple-ts/vite-plugin 内部未加保护的顶层 `process.platform` 访问）被打包进
  // 客户端 bundle，浏览器执行时抛 ReferenceError 直接中断整个 hydrate 客户端脚本，
  // 使 docs 站所有交互组件（Switch/Tag/Tabs 等）点击完全无响应。2026-08-13 用
  // Switch/Tabs 在 pnpm build 生产构建下真机复现确认，完整记录见
  // specs/cross-cutting/foundation-adapter-pattern.md 踩坑 #9。早先这里的注释
  // 曾错误宣称"page渲染/交互功能不受影响"——那是用没有任何交互逻辑的 Divider demo
  // 做的验证，属于假阴性，教训同样记录在踩坑 #9。
  optimizeDeps: {
    exclude: ['@ripple-ts/vite-plugin'],
  },
  appType: 'custom',
  plugins: [ripple()],
});
