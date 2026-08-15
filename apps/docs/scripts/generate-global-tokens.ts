import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

/**
 * 生成 src/components/global-tokens.tsrx：把 @lotus/tokens 构建产出的 tokens.css
 * 包装成一个 scoped <style> 组件，供 Ripple SSR 的 data-ripple-ssr 收集机制处理。
 *
 * 背景：普通 JS `import '.css'` 副作用导入在 Ripple SSR（RenderRoute 模式）下不会
 * 被收集进 <!--ssr-head-->，index.html 手写 <link> 指向 node_modules 包内文件也无法
 * 被 Vite dev server 用可移植路径解析。唯一验证过可行的方式是把 CSS 内容塞进组件的
 * scoped <style> 块（:root 规则不受 class scoped hash 影响，天然全局生效）。
 * tsrx 的 scoped style 解析器对 `@layer` at-rule 的支持未经验证，保守起见剥离最外层
 * `@layer lotus-tokens { ... }` 包裹，只保留内层的 :root 规则集。
 * 详见 specs/cross-cutting/docs-site.spec.md「调研依据」。
 *
 * 本脚本需要在 `pnpm --filter @lotus/tokens build` 之后运行（依赖 dist/tokens.css 是最新的）。
 */

const __dirname = dirname(fileURLToPath(import.meta.url));
const TOKENS_CSS_PATH = resolve(__dirname, '../../../packages/tokens/dist/tokens.css');
const OUTPUT_PATH = resolve(__dirname, '../src/components/global-tokens.tsrx');

function stripOutermostLayer(css: string): string {
  const trimmed = css.trim();
  const layerMatch = trimmed.match(/^@layer\s+[\w-]+\s*\{([\s\S]*)\}\s*$/);
  if (!layerMatch) return trimmed;
  return layerMatch[1]!.trim();
}

const rawCss = readFileSync(TOKENS_CSS_PATH, 'utf-8');
const cssBody = stripOutermostLayer(rawCss);

const output = `/**
 * 由 scripts/generate-global-tokens.ts 从 packages/tokens/dist/tokens.css 自动生成，不要手改。
 * 重新生成：pnpm --filter @lotus/tokens build && pnpm --filter @lotus/docs generate:tokens
 * 详见该脚本文件头注释，说明为什么全局 Token 要以 scoped <style> 组件形式注入而非普通 CSS import。
 */
export function GlobalTokens() @{
    <>
        <style>
${cssBody
  .split('\n')
  .map((line) => `            ${line}`)
  .join('\n')}
        </style>
    </>
}
`;

writeFileSync(OUTPUT_PATH, output, 'utf-8');
console.log(`[generate-global-tokens] wrote ${OUTPUT_PATH}`);
