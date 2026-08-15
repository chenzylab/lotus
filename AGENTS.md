# lotus — AGENTS.md

> lotus 是一套对标 [Semi Design](https://semi.design) 的组件库，使用 **tsrx**（`.tsrx` 语言）编写、编译到 **Ripple** 运行时。
> 本文件是项目总纲，供 AI Agent（Claude Code 等）在本仓库内工作时的第一入口。所有阶段性工作通过 `specs/` 下的 SPEC 文件驱动，具体操作规范下沉到 `.claude/skills/` 下的 SKILL。

## 0. 心智模型

- **源语言是 `.tsrx`，运行时目标是 Ripple。** tsrx 是类 JSX 的 TypeScript 超集语言，可编译到 React/Vue/Solid/Ripple 等多个目标；lotus 只启用 Ripple 目标（`@tsrx/ripple` / `@ripple-ts/vite-plugin`）。写代码前必读 `specs/references/tsrx-llms.txt` 与 `specs/references/ripple-llms.txt`。
- **架构分层参照 Semi 的 Foundation/Adapter (F/A) 模式**，但方向反过来：Semi 是"一套 Foundation 适配多个 UI 框架"，lotus 当前只有一个目标框架（Ripple），分层的意义在于——把**框架无关的状态机/业务逻辑**（Foundation）与**Ripple 渲染绑定代码**（Adapter）物理分开，为将来可能追加 tsrx 的其他目标（React/Vue/Solid）预留切面，并让核心逻辑可独立单测。不要过度设计：只有当组件存在非平凡状态机（受控/非受控切换、键盘导航、异步校验等）时才值得拆出 Foundation；纯展示组件（Divider、Space、Grid 等）直接写在 Adapter 层即可。
- **Design Token 独立设计，不 fork Semi 的变量体系**，但沿用其分层算法思路（品牌色 → 色阶 → 语义层 → 组件层）与 CSS 自定义属性交付形式。规范见 `specs/cross-cutting/theme-tokens.spec.md`。
- **本地 `~/i/semi-design` 仓库是可参考也可直接搬运的资产库**（图标 SVG、可复用的纯算法/纯逻辑代码、色彩算法思路），但lotus 是独立仓库、独立实现，不是 fork。搬运前必须过 `.claude/skills/semi-porting/SKILL.md` 的合规与改写检查清单（License、变量名去 semi 前缀、去除 React 专属实现细节）。
- **基础能力自研，不引入第三方运行时依赖**：浮层定位（Popover/Dropdown/Tooltip 的碰撞检测与自动翻转）、拖拽（DragMove/Resizable/Slider 的指针跟踪）、虚拟滚动（Table/Select/Tree 系列）这类能力，不直接依赖 Floating UI、react-window、interact.js 等第三方库作为运行时依赖。做法是**参考这些业界成熟实现的算法与边界处理思路**（可以阅读其源码/文档理解设计），在 `packages/foundation` 下用框架无关的 TypeScript 重新实现一遍，产出 lotus 自己的 `popupPosition.ts` / `dragTracker.ts` / `virtualList.ts` 等模块。原因：（1）保持 Foundation 层零外部运行时依赖，是它能被单测、被未来其他 tsrx 目标复用的前提；（2）第三方库的 API 设计通常绑定其目标框架的心智模型，直接包裹容易在 Ripple 的细粒度响应式模型下产生适配摩擦而非真正契合；（3）版本/体积/供应链完全自主可控。日期计算、Markdown/代码高亮解析这类"内容处理"而非"交互行为"的库，不受此条约束，可以正常作为依赖引入（决策记录在具体组件的实现说明中）。
- **对标全量组件**：目标是覆盖 Semi 官方文档收录的全部组件分类（Basic / Navigation / Data Entry / Data Display / Feedback / Other-AI），完整清单见 `specs/component-inventory.md`。分阶段交付，阶段划分见 `specs/phases/`。

## 1. 技术栈

| 领域 | 选型 | 说明 |
|---|---|---|
| 组件源语言 | `.tsrx` | 编译目标固定为 Ripple (`@tsrx/ripple`) |
| 运行时 | `ripple` | fine-grained reactivity，`track()`/`effect()`/`mount()`/`hydrate()` |
| 构建/开发服务器 | Vite + `@ripple-ts/vite-plugin` | 组件包、文档站、playground 统一使用 Vite |
| 包管理 | pnpm workspace | monorepo，见第 2 节目录结构 |
| 样式 | CSS 自定义属性 + 每组件 scoped `<style>` | 不用 CSS-in-JS 运行时方案；主题变量走 CSS Variables |
| 单元测试 | Vitest | 覆盖 Foundation 层状态机与工具函数 |
| 端到端/交互/视觉回归测试 | Playwright | 覆盖真实 DOM 交互、可访问性快照、视觉对比 |
| 文档站 | Vite + tsrx（自举：用 lotus 自己的组件搭文档站） | |
| Lint/Format | ESLint + Prettier（TS/tsrx 双解析器） | |
| 发布 | pnpm publish + changesets | 语义化版本，每个 package 独立版本 |

## 2. Monorepo 目录结构

```
lotus/
├── AGENTS.md                     # 本文件
├── DESIGN.md                     # 视觉设计语言摘要（色彩/字体/圆角/间距，来自品牌 token 决策）
├── specs/
│   ├── component-inventory.md    # Semi 全量组件清单 + 分类 + 阶段归属
│   ├── phases/                   # 分阶段 SPEC（Phase 0, 1, 2 ...）
│   └── cross-cutting/            # 横切能力 SPEC（主题/i18n/a11y/性能/测试/AI-ready/发布）
├── .claude/
│   └── skills/                   # 按工种拆分的 SKILL，供 Agent 调用
├── packages/
│   ├── tokens/                   # @lotus/tokens — Design Token 源 + 生成的 CSS 变量
│   ├── foundation/                # @lotus/foundation — 框架无关的组件逻辑层（每组件一个子目录）
│   ├── icons/                     # @lotus/icons — 图标（SVG 源 + 生成的 tsrx 组件）
│   ├── ripple/                    # @lotus/ripple — Ripple Adapter，真正对外发布的组件库
│   ├── locale/                    # @lotus/locale — i18n 文案包
│   └── cli/                       # @lotus/cli（可选，后置）— 主题定制/脚手架 CLI
├── apps/
│   ├── docs/                      # 文档站（自举用 @lotus/ripple 搭建）
│   └── playground/                # 手动验证/调试用的最小 Vite + Ripple 应用
├── e2e/                            # Playwright 测试（跨包，针对 apps/playground 或 docs 中的示例）
├── pnpm-workspace.yaml
└── package.json
```

**包依赖方向**：`tokens` ← `foundation` ← `ripple` ← `docs`/`playground`。`icons` 和 `locale` 被 `ripple` 消费。禁止反向依赖。

### 组件分类目录（对齐 Semi 官方分类）

`packages/foundation/src/` 与 `packages/ripple/src/` 内部**不使用扁平的 `<component>/` 目录**，而是按 Semi 官方文档站的分类体系分层组织，与 `specs/component-inventory.md` 的分类完全对应：

```
packages/ripple/src/
├── basic/          # Button, IconButton, Icon, Typography, Divider, Space, Grid, Layout, FloatButton, Resizable
├── navigation/      # Tabs, Breadcrumb, Steps, Pagination, Anchor, BackTop, Navigation, Tree
├── input/           # Input, InputNumber, Checkbox, Radio, Switch, Form, Select, Cascader, TreeSelect, AutoComplete, DatePicker, TimePicker, Slider, Rating, ColorPicker, Transfer, Upload, TagInput, PinCode
├── show/            # Avatar, Badge, Card, Tag, Empty, Descriptions, Collapse, Collapsible, Dropdown, Popover, Tooltip, List, Timeline, Image, Carousel, Modal, SideSheet, Calendar, OverflowList, ScrollList, Highlight, Cropper, UserGuide, Table
├── feedback/        # Banner, Notification, Toast, Popconfirm, Progress, Skeleton, Spin, Feedback(Result)
├── other/           # ConfigProvider, Locale
├── plus/            # CodeHighlight, MarkdownRender, JsonViewer, Chat, AudioPlayer, VideoPlayer, Lottie, DragMove, HotKeys, Sidebar
└── ai/              # AiChatDialogue, AiChatInput, AiComponent
```

每个组件目录内部结构不变（`index.tsrx` + 类型 + 样式，见 `component-authoring` skill）；变化的只是外层分类前缀。`packages/foundation/src/` 采用完全相同的分类结构，两边一一对应，import 路径按分类可预测（例如 `@lotus/foundation/input/select` 对应 `packages/ripple/src/input/select`）。文档站 `apps/docs` 的导航菜单、`packages/ripple` 的公共 `index.ts` 导出分组，均以此分类为准，与 Semi 官网导航保持用户认知一致。

**例外**：Icon/IconButton 虽属 `basic` 分类，但 `packages/icons` 作为独立包管理图标资产本身，`basic/` 目录下的 Icon 组件只是薄封装，实际 SVG 资源不受此分类结构约束。

## 3. 组件交付定义 (Definition of Done)

任何一个组件视为"完成"，必须同时满足：

1. **Foundation**（如需要）：`packages/foundation/<component>/foundation.ts` 纯逻辑类 + `packages/foundation/<component>/foundation.test.ts` 单测，不依赖 DOM/Ripple。
2. **Adapter 实现**：`packages/ripple/src/<component>/index.tsrx` + 该目录下 scoped `<style>` 或独立 `.scss`/`.css`。
3. **Token 消费**：组件样式 100% 使用 `var(--lotus-*)` 变量，不硬编码颜色/圆角/间距数值（校验规则见 `specs/cross-cutting/theme-tokens.spec.md`）。
4. **类型导出**：Props 类型完整、导出到包的公共 `index.ts`。
5. **文档示例**：`apps/docs` 下至少一个可运行示例页面。
6. **测试**：Foundation 单测（若有）+ 至少一条 Playwright 交互测试。
7. **无障碍**：过 `.claude/skills/a11y-audit/SKILL.md` 检查清单（键盘导航、ARIA、对比度）。
8. **国际化**：面向用户的文案全部走 `@lotus/locale` token，不硬编码中/英文字符串。
9. **性能**：若组件属于列表/大数据类（Table/Tree/Select/Cascader/TreeSelect 等），必须有 `specs/cross-cutting/perf-baseline.spec.md` 定义的基线数据与虚拟化开关。

## 4. SKILL 索引

Agent 在执行对应工作前，应先 `Skill` 调用相应技能获取详细 checklist，而非凭记忆操作。

| Skill | 用途 | 触发时机 |
|---|---|---|
| `component-authoring` | 从 0 实现一个 Ripple 组件（Adapter 层） | 新增/重写某组件的 `.tsrx` 实现 |
| `foundation-authoring` | 编写框架无关的 Foundation 状态机 | 组件存在非平凡交互逻辑时 |
| `semi-porting` | 从本地 `~/i/semi-design` 搬运可复用资产 | 需要参考或移植图标/算法/逻辑代码时 |
| `theme-tokens` | 设计/新增/校验 Design Token | 新组件引入新语义变量、主题定制需求 |
| `i18n-locale` | 新增语言包、校验文案无硬编码 | 组件涉及用户可见文案时 |
| `a11y-audit` | 无障碍自检 | 每个组件完成前必跑 |
| `perf-baseline` | 建立/校验性能基线 | 大数据量组件（Table/Tree/Select 系列） |
| `testing` | 编写 Vitest/Playwright 测试 | 每个组件/每个 SPEC 收尾 |
| `release` | 版本发布流程 | 阶段性发布节点 |

每个 SKILL 目录下必须有 `SKILL.md`（说明 + checklist）。

## 5. SPEC 驱动的开发流程

1. 所有实质性开发工作对应 `specs/phases/phase-N-*.spec.md` 或 `specs/cross-cutting/*.spec.md` 中的一份 SPEC。
2. 开工前先读对应 SPEC 的「目标」「范围」「验收标准」「依赖 Skill」。
3. SPEC 内的组件清单勾选状态即项目进度看板，完成一项即在 SPEC 文件内打勾（`- [x]`），不要另开进度文档。
4. 跨阶段的横切能力（主题、i18n、a11y、性能、测试、发布）不重复在每个 Phase SPEC 里展开，统一引用 `specs/cross-cutting/` 对应文件。
5. Phase 完成的定义：该 Phase SPEC 里列出的组件全部满足第 3 节 Definition of Done。

## 6. 开发原则（继承自用户全局开发八荣八耻，此处补充项目特化条款）

- **真跑起来看**：tsrx/Ripple 生态工具链新，任何一次"应该能编译/应该能跑"都必须用 `pnpm --filter <pkg> dev` 或 `vitest run` 实测验证，不凭对 React 生态的经验拍板。
- **对齐源码而非文档**：本文档基于 tsrx/Ripple 官方 `llms.txt`（截至 2026-08）与 Semi 8 篇设计博客整理，工具链可能已演进；实现前用 `WebFetch` 或本地缓存复核 `specs/references/` 下的原始资料是否过期。
- **Foundation 先写测试**：Foundation 层是唯一能脱离 Ripple 运行时跑单测的部分，新状态机逻辑必须先有 Vitest 用例。
- **搬运必须改写，不做贴牌**：从 `~/i/semi-design` 借鉴的代码，变量命名、CSS 前缀（`--lotus-*` 而非 `--semi-*`）、类名前缀（`.lotus-*`）必须全部替换，不允许残留 `semi` 字样。
- **Token 变更是破坏性变更**：`packages/tokens` 的变量一旦发布，重命名/删除按 semver major 处理，新增语义变量走 minor。

## 7. 参考资料快照

以下原始资料已抓取归档到 `specs/references/`，供离线查阅，避免重复联网：

- `tsrx-llms.txt` — tsrx 语言官方 AI 文档（https://tsrx.dev/llms.txt）
- `ripple-llms.txt` — Ripple 运行时官方 AI 文档（https://www.ripple-ts.com/llms.txt）
- `semi-design-articles.md` — Semi 8 篇设计博客要点摘录（AI/i18n/Performance/PerfBaseline/FA/UITest/Theme/Accessibility）
- `semi-customize-theme.md` — Semi 主题定制官方文档要点

本地只读参考仓库：`~/i/semi-design`（Semi Design 源码，用于 API 设计比对与资产搬运，见 `semi-porting` skill）。
