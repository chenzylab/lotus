import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  reporter: 'list',
  use: {
    baseURL: 'http://localhost:48213',
  },
  webServer: {
    // 注意：不要写成 `pnpm --filter <pkg> dev -- --port <port>`——pnpm 会把 `-- --port <port>`
    // 原样透传给底层的 `vite` 命令，产生 `vite -- --port <port>`，Vite 把 `--port <port>` 当作
    // 位置参数（entry 路径）而非选项，端口选项被忽略，实际监听在默认的 5173，导致 Playwright
    // 一直探测不到目标端口而超时。直接指定 `--filter <pkg> exec vite --port <port>` 绕开
    // package.json script 的二次 `--` 转发层。
    //
    // 端口选用 48213 这种高位号段，而非 5170-5260 附近的常见开发端口——本机同时开着多个
    // 其他项目的 vite dev server，都在那个号段抢号，曾经导致 Playwright 的 reuseExistingServer
    // 误连别的项目、Tree 组件的全部 aria-label 定位器返回 0 元素。高位端口撞车概率低得多。
    command: 'pnpm --filter @lotus/playground exec vite --port 48213',
    url: 'http://localhost:48213',
    reuseExistingServer: !process.env.CI,
    timeout: 30_000,
  },
});
