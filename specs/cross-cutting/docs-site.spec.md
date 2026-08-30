# 横切能力 SPEC — 文档站 (apps/docs)

> `apps/docs` 是 lotus 的组件文档站，Phase 0 明确排除在外，Phase 1 中途启动。
> 技术方案基于对 tsrx/Ripple 官方文档站（ripple-ts.com / tsrx.dev）的实测调研，
> 详见下方「调研依据」——**不是凭空设计，是理解官方真实生产架构后用 lotus 自己的实现重写**。

## 调研依据（2026-08-12 实测，非猜测）

调研方式：本地克隆的 `~/i/ripple`（Ripple-TS/ripple monorepo）源码阅读 + `gh api` 核对 GitHub 最新提交 + Chrome 真机访问 `ripple-ts.com` 线上站点并用 Network 面板抓包验证。

### 正文渲染管线（`website-new/src/lib/markdown.js`）

- **`.md` 是唯一内容源**，不是"人工维护两份内容"。`website-new/docs/**/*.md`（标准 Markdown + frontmatter）通过 Vite 的 `import.meta.glob(..., { query: '?raw', eager: true })` 在构建时整体读入为字符串。
- 用 **`marked`**（Markdown → HTML 解析器）+ **`shiki`**（代码高亮，自定义加载了 `grammars/textmate/ripple.tmLanguage.json` 实现 tsrx/ripple 语法高亮）在服务端把 md 解析成最终 HTML。
- 页面侧用 Ripple 的 `module server { ... }` 特性声明 `load_doc()`，组件里 `import { load_doc } from server` 调用，拿到 `{ html, title, toc, editPath, prev, next }`，用 `<div class="doc-content" innerHTML={doc.html} />` 注入：
  ```tsrx
  import { DocsLayout } from '../../components/docs-layout.tsrx';

  module server {
      import { get_doc } from '../../lib/markdown.js';
      export function load_doc() { return get_doc('quick-start'); }
  }

  import { load_doc } from server;

  export function QuickStartPage() @{
      const doc = load_doc();
      <DocsLayout title={doc.title} toc={doc.toc} ...>
          <div class="doc-content" innerHTML={doc.html} />
      </DocsLayout>
  }
  ```
- 处理的 Markdown 扩展语法：VitePress 风格的 `::: info/tip/warning/danger/details` 容器块、frontmatter（`title` 等）、标题自动生成锚点 id 并提取 TOC、`<Code>...</Code>` 标签包裹代码块生成 tab UI 容器。
- **17 个文档页面里 16 个用这套 `get_doc` 管线**，只有最早的 `introduction.tsrx` 是历史遗留的手写页面（未跟上重构），说明这是当前的标准模式，不是个例。

### Demo/Playground 展示（实测 Network 面板抓包确认）

- 文档正文代码块默认显示"Code"tab（`shiki` 静态高亮的源码），旁边有"Playground"tab。
- **点击 Playground 后实际加载的是一个 iframe，嵌入独立部署的 LiveCodes 实例**：`https://ripple.livecodes.pages.dev/?loading=eager&embed=true&sdkVersion=0.13.0&config=sdk`（LiveCodes 是一个支持自定义语言插件的开源在线代码演练场引擎，`website-new/package.json` 依赖的 `livecodes` 包是其 embed SDK 客户端）。
- 这不是 lotus 现阶段要跟进的方案（自部署 LiveCodes + 自定义语言插件是较重的独立基础设施投入，不在文档站首个可用版本的范围内）。

### 对 lotus 的最终取舍

| 能力 | Ripple 官方方案 | lotus 方案 | 理由 |
|---|---|---|---|
| 正文渲染 | md → marked/shiki → innerHTML | **完全参照**：md → marked/shiki → innerHTML，用 `module server` | 架构成熟、可验证、无需发明新方案 |
| 代码高亮 | shiki + 自定义 tmLanguage | **完全参照**：shiki，复用 tsrx 官方 grammar（若可获取）或参照其结构自制 | 同上 |
| Demo 可交互性 | LiveCodes 自部署在线编辑器 | **简化**：demo 是独立 `.tsrx` 文件，构建时被文档页面直接 `import` 渲染成真实组件（真实可交互，但不可在线编辑源码） | LiveCodes 自部署是重基础设施，非首版必需；「真实渲染的 demo」已能满足「每个 demo 真机验证」的核心诉求 |
| 代码展示 | Code/Playground 双 tab | **简化为单一静态高亮块** + demo 组件在其下方直接渲染 | 不需要 tab 切换的编辑器嵌入逻辑 |

后续如有必要，可重新评估是否投入 LiveCodes 自部署或等价方案，补齐"在线编辑"能力，不影响当前架构（demo 目录结构不变，只是给每个 demo 增加一个可选的"在线编辑"入口）。

## 目标

产出结构对齐 Semi 官方文档（章节顺序：代码演示 → API 参考 → Accessibility → 文案规范 → 设计变量），每个 demo 真机验证可用。

## 目录结构

```
apps/docs/
├── docs/                          # Markdown 内容源，按组件分类目录组织，与 packages/ripple/src 分类一致
│   └── basic/
│       └── button.md
├── src/
│   ├── lib/
│   │   └── markdown.ts            # get_doc(slug) 实现：frontmatter 解析 + marked + shiki + TOC 提取
│   ├── components/
│   │   ├── docs-layout.tsrx        # 文档页整体布局（侧边导航 + 正文 + 右侧 TOC）
│   │   ├── doc-code-block.tsrx     # 静态代码高亮块
│   │   └── doc-api-table.tsrx      # API 参考表格渲染（若 md 表格语法不够用再补）
│   ├── demos/                     # 每个组件的 demo 源码，真实 .tsrx 文件，与 docs/ 分类结构一一对应
│   │   └── basic/
│   │       └── button/
│   │           ├── basic.tsrx      # 基础用法
│   │           ├── theme.tsrx      # 主题变体
│   │           └── ...
│   └── pages/
│       └── basic/
│           └── button.tsrx         # module server { get_doc('basic/button') } + demos import + 渲染
├── ripple.config.ts
├── vite.config.ts
└── package.json
```

## Markdown 文档章节规范（对齐 Semi，每个组件 md 必须包含）

参照 `~/i/semi-design/content/basic/button/index.md` 的结构：

1. Frontmatter：`title`、`category`（对应分类目录）
2. `## 代码演示`：每个二级/三级小节一个场景说明 + 对应 demo 引用（约定语法见下）
3. `## API 参考`：按子组件分表格，列：属性 | 说明 | 类型 | 默认值（可选加"版本"列）
4. `## Accessibility`：ARIA 属性说明 + 键盘操作说明
5. `## 文案规范`（如适用）：组件文案的推荐/不推荐对比
6. `## 设计变量`：该组件消费的 `--lotus-*` Token 列表

## Demo 引用约定

md 正文中用 fenced code block 加语言标注 `tsrx demo` 表示"这是一个 demo 引用"，内容是 demo 文件的相对路径（而非直接内联源码），构建时脚本解析出路径、真实读取 `.tsrx` 源码用于高亮展示，同时页面组件侧显式 `import` 该 demo 组件渲染出真实交互效果：

```markdown
### 按钮类型

按钮支持以下类型：主要、次要、第三、警告、危险。

​```tsrx demo
./basic.tsrx
​```
```

具体解析实现见 `src/lib/markdown.ts`，需要在 `get_doc` 基础上扩展对 ` ```tsrx demo ` 代码块的识别（Ripple 官方没有这个语法，是 lotus 针对"demo 与源码同源"这个需求的必要扩展）。

## 验收标准

- [x] `apps/docs` 可独立 `pnpm dev` 启动，路由与 `packages/ripple/src` 分类结构一致（实测：`/basic/divider` 真机渲染验证通过）
- [x] `get_doc(slug)` 的 Vitest 单测覆盖：frontmatter 解析、代码高亮、TOC 提取、`tsrx demo` 引用解析（10 个测试，含针对真实 `docs/basic/divider.md` 的集成测试）
- [ ] 每个已完成组件（对照 `specs/component-inventory.md` 打勾状态）都有对应 `docs/<category>/<component>.md`，章节结构符合上方规范——**此前"当前只有 Divider 一个"的记录已严重滞后于实际代码**：实测 `apps/docs/docs/` 下已有 21 篇（`basic/{button,divider,grid,layout,space,typography}`、`feedback/skeleton`、`input/{checkbox,form,input,input-number,radio,select,switch}`、`navigation/{breadcrumb,navigation,tabs}`、`show/{avatar,dropdown,popover,tag,tooltip}`），对照 `packages/ripple/src` 下 82 个组件目录，仍缺 61 篇（basic 5 个、feedback 6 个、input 12 个、navigation 6 个、other 1 个、show 31 个）。经用户确认现在开始补齐，逐分类分批推进，每篇要求对齐 Semi 文档结构 + ego-browser 真机验证
- [x] 每个 demo 用 Chrome 真机渲染验证一次（Divider 的两个 demo 均截图确认渲染正确，含响应式/交互场景）
- [x] 文档站本身作为 `pnpm -r build` 的一部分纳入 CI（新增 `apps/docs` 后同步更新根 `package.json` 的 `build`/`typecheck` 脚本 filter 范围）——实测 `pnpm --filter @lotus/docs run build`/`run typecheck` 均成功（`apps/docs` 包名 `@lotus/docs`，被根 `package.json` 的 `--filter=./apps/*` 通配正确覆盖），CI `ci.yml` 的 `Build`/`Typecheck` 步骤运行 `pnpm build`/`pnpm typecheck` 会一并覆盖，无需额外配置

## 实测落地结论（与上方「调研依据」设计意图的实际出入，2026-08-12）

### `getDoc` 是同步函数，不是 async；返回片段数组，不是单一 html 字符串

设计阶段假设照抄官方 `get_doc(slug)` 直接返回 `{ html, title, toc }`。实测发现两个必须调整的点：

1. **官方整篇文档渲染成单一 HTML 字符串 + `innerHTML` 注入，代码演示只是静态高亮**（可交互 Playground 走 iframe 内嵌独立部署的 LiveCodes，不在同一渲染树里）。lotus 要求 demo 是"真实渲染、真实可交互"的 Ripple 组件，但 tsrx 组件必须静态 import、innerHTML 字符串里也无法混入真实组件实例（未找到可行方案，评估后放弃）。**解法**：`getDoc` 不返回单一 `html` 字符串，而是返回 `DocFragment[]`（`{type: 'html', html}` 与 `{type: 'demo', demo, highlightedSource}` 交替），页面组件用 `@for` 遍历渲染，`demo` 类型片段对应一个页面侧手写的"引用路径 → 真实组件"静态映射表（`DEMO_COMPONENTS: Record<string, any>`）。
2. **Ripple 组件函数体内不允许 `await`**（`tsrx-tsc` 报错：`await is not allowed inside components. Use trackAsync(...) with an upstream @try {...} @pending {...} boundary instead`）。官方 `markdown.js` 用**模块顶层 await** 提前初始化 shiki highlighter（`const highlighter = await createHighlighter(...)`），使 `get_doc` 本身保持完全同步，`module server` 里可以直接同步调用。lotus 照抄这个模式，`getDoc` 是同步函数，`highlighter` 是模块顶层 `await` 初始化的单例。

### 全局 CSS Token 注入：`import '.css'` 在 Ripple SSR 下不生效，改用 scoped `<style>` 组件承载

`@lotus/tokens` 是独立发布的 CSS 变量文件（近 400 个变量），需要在文档站全局生效。三种方案实测结果：

1. **`import '@lotus/tokens/css'`（普通 JS 模块副作用 import）——不生效**。curl 检查 SSR 输出的 `<!--ssr-head-->` 位置完全没有对应内容，说明这种 import 在 `RenderRoute` SSR 模式下不会被收集注入。
2. **`index.html` 手写 `<link rel="stylesheet" href="/@lotus/tokens/dist/tokens.css">`——404**。Vite 对 `node_modules` 内文件没有这种虚拟路径映射；改用 `/@fs/<绝对路径>` 能拿到 200，但绝对路径硬编码不可移植（不同开发者机器路径不同），排除。
3. **把 CSS 内容包装进组件的 scoped `<style>` 块——可行，最终采用**。Ripple SSR 已验证过能正确收集 scoped `<style>` 内容并通过 `data-ripple-ssr` 属性输出到 `<!--ssr-head-->`（Phase 0/1 组件自身样式一直是这样工作的）。`:root { ... }` 规则不受 class scoped hash 影响，天然全局生效，不需要额外用 `:global()`。**tsrx scoped style 解析器对 `@layer` at-rule 的支持未经验证**，保守起见用脚本剥离 `tokens.css` 最外层的 `@layer lotus-tokens { ... }` 包裹，只保留内层 `:root` 规则集。

落地为 `apps/docs/scripts/generate-global-tokens.ts`：读取 `packages/tokens/dist/tokens.css`，剥离 `@layer` 包裹后生成 `src/components/global-tokens.tsrx`（自动生成，文件头注明不要手改），`package.json` 用 `predev`/`prebuild` hook 保证每次开发/构建前自动重新生成，不依赖开发者手动记得跑。

### 已知的 dev-only 噪音报错（不阻塞，已记录不掩盖）

Vite dev 模式下 esbuild 依赖预构建（`optimizeDeps`）会把 Node-only 的 Ripple 工具链包误纳入客户端扫描范围，浏览器控制台出现噪音报错：

- `ReferenceError: process is not defined`（来自 `@ripple-ts/vite-plugin` 的客户端预构建产物）——**已通过 `vite.config.ts` 的 `optimizeDeps.exclude: ['@ripple-ts/vite-plugin']` 消除**。
- `Error: Module "node:fs/promises" has been externalized for browser compatibility`（来自 `@tsrx/core` 内部 `src/vite/dep-scan.js` 子模块）——**尝试同样的 exclude 未能消除**（`@tsrx/core` 依赖链更复杂，顶层包名排除对内部子模块无效），评估继续深挖的排查成本已超过其影响，暂不追加投入。

**两者均实测确认只出现在 dev 模式**：`pnpm build` + `node dist/server/entry.js` 生产构建服务器完全无此报错（chunk 列表里也不包含这些包），且 dev 模式下页面渲染/交互功能不受影响（Divider 两个 demo 真机验证均正常工作，含响应式布局场景）。后续若官方修复或发现更优雅的规避方式，可再更新此记录。

### Demo 组件的静态映射表模式（跑通但存在可预见的维护成本）

`DEMO_COMPONENTS: Record<string, any>` 这种"手写路径字符串 → 组件引用"的映射表，每新增一个 demo 文件都要在页面组件里手动加一行 import + 一行映射，组件数量增多后容易漏写/写错路径（拼写错误只能靠运行时 `MissingDemo` 兜底提示发现，不是编译期报错）。Phase 1 组件量少（当前 1 个组件 2 个 demo）时可接受，**后续组件增多后应评估是否值得写一个构建时代码生成脚本**（扫描 `docs/**/*.md` 里的 `tsrx demo` 引用，自动生成页面文件的 import 列表 + 映射表，类似 `generate-global-tokens.ts` 的思路），而不是继续手写。此优化不阻塞当前进度，记录为已知的技术债务。
