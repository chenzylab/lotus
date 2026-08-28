# 横切能力 SPEC — Design Token / 主题系统

> 被所有 Phase SPEC 引用。定义 `@lotus/tokens` 包的产出物、命名规范、算法要求与验收标准。
> 设计依据：`specs/references/semi-design-articles.md` 「Theme」「customize-theme」两节。
> **数值权威来源分两级**：`~/i/semi-design/DESIGN.md` 是摘要级参照（够快速上手，但不完整）；
> `~/i/semi-design/packages/semi-theme-default/scss/{global.scss,variables.scss}` 是完整一手源码
> （构建产物直接消费的源头，包含 DESIGN.md 未提及的大量分类：语义色浅版三态、5 层背景、4 层文字、
> 9 级间距、Z-index、字重、控件高度、描边宽度、link/highlight/overlay/shadow 等）。
> **设计 Token 体系前必须先读完整源码，不要只看 DESIGN.md 摘要就开始实现**——Phase 1 曾因为
> 只参照 DESIGN.md 摘要导致 Token 体系严重不完整（缺失上述近一半分类），被迫推翻重写，
> 详见 `specs/cross-cutting/foundation-adapter-pattern.md` 相关记录。不允许"当前组件够用就行"
> 的零散补丁式设计——Token 是先于组件的基础设施，必须在动手写第一个消费 Token 的组件之前就设计完整。

## 目标

产出一套独立的、四层分级的 CSS 自定义属性体系，支持「改一个品牌色 → 自动生成完整色阶 → 级联到所有组件」的主题定制能力，同时原生支持亮/暗双模式与 AI 专属色彩。

## 命名规范

- 前缀统一 `--lotus-`，不得出现 `--semi-` 字样（含搬运代码）。
- 分层前缀：
  - `--lotus-palette-{hue}-{0-9}`：L4 基础色阶（如 `--lotus-palette-blue-5`）
  - `--lotus-color-{semantic}`：L3 全局语义变量（如 `--lotus-color-primary`、`--lotus-color-danger`、`--lotus-color-ai-general`）
  - `--lotus-{component}-{property}`：L2 组件级变量（如 `--lotus-button-radius`）
  - 组件样式（L1）直接消费 L2，L2 默认引用 L3，形成级联覆盖链
- 状态后缀：`-hover` / `-active` / `-disabled` / `-focus`，与 Semi 的后缀约定保持一致（用户认知成本低，非技术耦合）。

## 色彩算法要求

- 输入：单一品牌色（HEX/HSB）。
- 输出：该色相的 0-9 十级色阶，且暗色模式自动降饱和度、提明度（不是简单取反或降低亮度这类朴素算法）。
- **不直接复制 Semi 的算法代码**，但可参照其思路重新实现：色相环分段、锚点色相的 Peak Chroma 明度差异、品牌色相对锚点的偏移量计算。算法实现前用 `semi-porting` skill 的流程评估 Semi 算法的可学习部分（阅读理解、独立重写），而非逐行翻译。
- 至少覆盖 Primary/Secondary/Tertiary/Success/Warning/Danger/Info 七个语义色 + AI 专属渐变色（General/Purple + 背景渐变 Top/Bottom）。

## AI 色彩变量（Phase 1 起消费，Phase 6 深度使用）

- `--lotus-color-ai-general`：渐变色（多 stop，蓝紫粉），用于 AI 能力标识的主色。
- `--lotus-color-ai-purple`：纯色，AI 次要强调色。
- `--lotus-color-ai-background-top` / `--lotus-color-ai-background-bottom`：AI 区域背景渐变叠加层。
- 每个 AI 色需要 `-hover`/`-active`/`-disabled` 变体。

## 交付形态

- `packages/tokens/src/`：TypeScript/脚本形式的算法源（品牌色 → 色阶生成逻辑，可单测）。
- `packages/tokens/dist/tokens.css`：构建产出的 CSS 变量文件，用 `@layer lotus-tokens { :root { ... } }` 包裹（参照 Semi `cssLayer` 思路，方便消费方样式优先级可控）。
- 暗色模式通过 `:root[data-theme="dark"]` 或 `prefers-color-scheme` 媒体查询双轨支持（具体策略在 Phase 0 实现时确定并记录）。
- 提供一个 Vite 插件（`packages/tokens` 或独立 `packages/vite-plugin-lotus-theme`，视 Phase 0 实现复杂度决定拆分与否）支持运行时变量覆盖注入，等价于 Semi 的 `variables` 参数。

## 完整分类清单（Phase 1 补全后的基准，新增变量前先核对是否已有归属分类）

- **色相基础色阶**（L4）：7 语义色相（primary/secondary/tertiary/success/warning/danger/info）各 10 级
- **语义色完整状态集**（L3）：每色相 default/hover/active/disabled + 浅版三态 light-default/light-hover/light-active（暗色模式浅版用同基准色叠加 0.2/0.3/0.4 alpha，非取色阶）
- **背景层级**：bg-0 ~ bg-4，共 5 层
- **填充层级**：fill-0 ~ fill-2，共 3 层
- **文字层级**：text-0 ~ text-3，共 4 层（text-3 即 disabled-text，非重复定义）
- **边框类**：border（默认）、shadow-border（模拟描边阴影）、focus-border、disabled-border
- **禁用态四件套**：disabled-bg/text/border/fill
- **链接色**：link 的 default/hover/active/visited 四态
- **高亮色**：highlight-bg、highlight（文字）
- **蒙层**：overlay-bg
- **阴影**：shadow-elevated（浮层提升阴影）
- **圆角**：extra-small/small/medium/large/circle/full
- **间距**：完整 9 级（none/super-tight/extra-tight/tight/base-tight/base/base-loose/loose/extra-loose/super-loose）
- **控件高度**：small/default/large 三档
- **描边宽度**：none/control/control-focus
- **Z-index**：覆盖 portal/affix/backTop/badge/tableFixed/modal/toast/notification/popover/dropdown/tooltip/imagePreview/dragItemMove 等常见层叠冲突场景
- **字体**：font-family、字重 light/regular/bold 三档、完整排印刻度 h1-h6/body/label（各含 size/line-height/weight）
- **图标尺寸**：extra-small/small/medium/large/extra-large
- **AI 专属色**：general（渐变）、purple（含 hover/active/disabled）、background-top/bottom（含 hover/active/disabled）
- **数据可视化调色板**（data-0~19）：~~暂缓~~ 已交付，见 `packages/tokens/src/static-tokens.ts` 的 `chartDataColor`——亮暗模式各自独立的 20 色（不是共用同一套），数值来源 `~/i/semi-design/packages/semi-theme-default/scss/global.scss` 的 `--semi-color-data-0~19`（`:root`/`body[theme-mode="dark"]` 两个块分别定义，一手来源，非 VChart 主题包自己的兼容兜底值——踩坑细节见 `specs/cross-cutting/foundation-adapter-pattern.md`）

## 验收标准（每次 Token 变更/新增均需检查）

- [ ] 新增/修改的变量遵循命名规范，无 `--semi-` 残留
- [ ] 新增变量前已核对上方「完整分类清单」，确认不是应该归入已有分类的遗漏项（避免同一概念用不同名字重复定义）
- [ ] 色彩类变量在亮/暗两种模式下都定义了值，且暗色模式不是简单取反
- [ ] **对比度检查按正确的 WCAG 场景分类，不能一律套用常规文本 4.5:1**：
  - 正文文本（text-0/1/2 on bg-0/1）：≥ 4.5:1
  - 大文本（≥18px 或加粗 ≥14px）：≥ 3:1
  - UI 组件边界（如输入框描边与背景）：≥ 3:1
  - **实心色块按钮上的文字**（如 Solid 按钮白字）：Semi 生产环境验证此场景本就可能低于 3:1（如 Danger `#F93920` 白字仅 3.73、Success `#3BB346` 白字仅 2.72——已实测记录在 `packages/tokens/src/contrast.test.ts`），**不要生搬 4.5:1 或 3:1 断言逼迫改色**，而是如实记录实测数值，只挡"完全不可辨识"的下限（如 < 1.5）
  - 对比度计算/校验用 `packages/tokens/src/contrast.ts` 的 `contrastRatio`，不要凭肉眼判断，也不要假设"应该达标"而不实测——已发生过算法产出的真实数值与直觉相反的案例
- [ ] 交互状态变量（hover/active/focus）与相邻背景色对比度 ≥ 3:1（Tertiary 语义色例外，见「已知设计权衡」）
- [ ] 变量变更影响面已用 `grep` 确认（哪些组件消费了该变量），破坏性变更（重命名/删除）已在变更说明中标注 semver 影响
- [ ] `pnpm --filter @lotus/tokens build` 产出的 CSS 文件体积、变量总数有记录（用于后续版本间对比，规避意外膨胀）——Phase 1 完整版基准：388 个变量

## 已知设计权衡（不是缺陷，勿"修复"）

- **Tertiary 语义色**（`#6B7075`）定位是"第三级操作、中性图标"（DESIGN.md 原文），不是用于"实心背景+白字"的强调色，其品牌色对白字对比度天然较低，这是设计意图，不纳入 button-label 对比度检查范围。
- **Success/Warning/Danger 的 Solid 按钮白字对比度低于教科书式 4.5:1 标准**，是 Semi 官方生产环境的既有权衡（已用本地源码核实其真实使用白色文字），lotus 品牌色沿用相同数值故继承同样权衡。若未来 lotus 品牌色独立于 Semi 演进，可重新评估是否要更保守的取值，但不应假设当前数值是"未修复的 bug"。
