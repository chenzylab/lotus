import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  reporter: 'list',
  use: {
    baseURL: 'http://localhost:5183',
  },
  webServer: {
    // 注意：不要写成 `pnpm --filter <pkg> dev -- --port 5183`——pnpm 会把 `-- --port 5183`
    // 原样透传给底层的 `vite` 命令，产生 `vite -- --port 5183`，Vite 把 `--port 5183` 当作
    // 位置参数（entry 路径）而非选项，端口选项被忽略，实际监听在默认的 5173，导致 Playwright
    // 一直探测不到 5183 而超时。直接指定 `--filter <pkg> exec vite --port <port>` 绕开
    // package.json script 的二次 `--` 转发层。
    command: 'pnpm --filter @lotus/playground exec vite --port 5183',
    url: 'http://localhost:5183',
    reuseExistingServer: !process.env.CI,
    timeout: 30_000,
  },
});
