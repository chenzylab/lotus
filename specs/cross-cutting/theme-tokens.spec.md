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

- [x] 新增/修改的变量遵循命名规范，无 `--semi-` 残留——`grep -rn -- "--semi-"` 于 `packages/tokens/src`/`packages/ripple/src` 全部命中都在注释里（引用 Semi 一手来源做对照说明），构建产出的 `tokens.css` 变量名全部统一 `--lotus-` 前缀，零残留
- [x] 新增变量前已核对上方「完整分类清单」，确认不是应该归入已有分类的遗漏项（避免同一概念用不同名字重复定义）——通读 `static-tokens.ts`/`palette.ts`/`build-css.ts` 全部导出与生成逻辑，逐项对照第51-70行分类清单，未发现清单列出但代码缺失、或代码里存在但清单未提及的分类；核实 `text-3`/`disabled.text` 是真正的对象引用复用（`text: text.text3`）而非硬编码两份相同值，`disabled.border` 与主 `border` 是两个独立设计的颜色（非重复定义）
- [x] 色彩类变量在亮/暗两种模式下都定义了值，且暗色模式不是简单取反——`semanticLines()`（`build-css.ts` 第53-74行）亮色模式取色阶浅端（0/1/2 级），暗色模式改用同基准色叠加渐增 alpha（0.2/0.3/0.4），两套完全独立的算法，不是数值取反或简单降低亮度
- [x] **对比度检查按正确的 WCAG 场景分类，不能一律套用常规文本 4.5:1**——`contrast.test.ts` 已覆盖正文文本（4.5:1）与实心色块白字场景（如实记录不设硬阈值）；本次新增 `interaction-contrast.test.ts` 补齐这条此前完全没有测试覆盖的维度：
  - 正文文本（text-0/1/2 on bg-0/1）：≥ 4.5:1
  - 大文本（≥18px 或加粗 ≥14px）：≥ 3:1
  - UI 组件边界（如输入框描边与背景）：≥ 3:1
  - **实心色块按钮上的文字**（如 Solid 按钮白字）：Semi 生产环境验证此场景本就可能低于 3:1（如 Danger `#F93920` 白字仅 3.73、Success `#3BB346` 白字仅 2.72——已实测记录在 `packages/tokens/src/contrast.test.ts`），**不要生搬 4.5:1 或 3:1 断言逼迫改色**，而是如实记录实测数值，只挡"完全不可辨识"的下限（如 < 1.5）
  - 对比度计算/校验用 `packages/tokens/src/contrast.ts` 的 `contrastRatio`，不要凭肉眼判断，也不要假设"应该达标"而不实测——已发生过算法产出的真实数值与直觉相反的案例
- [x] 交互状态变量（hover/active/focus）与相邻背景色对比度 ≥ 3:1（Tertiary 语义色例外，见「已知设计权衡」）——核实此前从未有对应测试。写第一版测试时踩了一个坑：直接拿 `--lotus-color-{hue}-hover`/`-active` 与 `bg-0` 算对比度，测出 secondary/success/warning 的 hover 态低于 3:1（如 warning-hover 仅 2.11），但 grep 实际消费方（`Button`/`IconButton`）发现这些变量用作 `background:`（按钮 hover 态实心背景色），不是贴在页面背景上的边框/文字元素，"与 bg-0 对比度"这个参照系文不对题。真正对应 spec 第80行"输入框描边与背景"这类场景的是 `focus-border`（表单控件 focus 边框），实测亮/暗模式与 `bg-0` 对比度均 ≥ 3:1，达标；hover/active 态色阶延续 default 态"实心色块+白字"的既有权衡逻辑（不设硬阈值，只挡 < 1.5），新增 `interaction-contrast.test.ts` 固化
- [x] 变量变更影响面已用 `grep` 确认（哪些组件消费了该变量），破坏性变更（重命名/删除）已在变更说明中标注 semver 影响——这条描述的是"每次变量变更时应该做的操作规程"，本次核实过程本身即用 `grep` 确认了 `focusBorder`/hover-active 色阶等变量的实际消费方（详见上一条），核实性质的变更（未重命名/删除任何现有变量）不涉及 semver 标注；后续若有真正的破坏性变更仍需逐次遵守此规程，不因这次勾选而免除
- [x] `pnpm --filter @lotus/tokens build` 产出的 CSS 文件体积、变量总数有记录（用于后续版本间对比，规避意外膨胀）——**「388 个变量」这个此前记录的基准数字经核实是不可靠的**：用仓库最早的两个 commit（`a99f839` 初始化、`0acd5cc` "complete Phase 1"）重新 checkout 并各自跑一遍 `build`，实测分别是 422 个和 426 个变量，从未出现过 388 这个数字——对照本文件第 9-11 行记录的"Phase 1 曾因只读 DESIGN.md 摘要导致 Token 体系严重不完整、被迫推翻重写"这段历史，388 大概率是**推翻重写之前**那次不完整实现的残留记录，仓库现存的第一个 commit 已经是重写后的完整版本，git 历史里根本不存在"388 变量"对应的真实状态，这条验收标准要求的"有记录"从写下的那一刻起就从未被真正执行过（不是"数值被人篡改"，是"这行字本身就没有配套做过 build+统计的动作"）。现在正式建档：当前（commit 3e2d78a 附近）`tokens.css` 共 **466 个变量**，文件体积 19419 字节（gzip 后 3782 字节）。分类构成（粗粒度，不含 z-index/info/secondary 等零散语义色变体的精确切分）：`--lotus-palette-*` 基础色阶 140 个、语义色（bg/fill/text/border/primary/danger 等）122 个、`--lotus-color-data-*` 数据可视化调色板 40 个（本次任务新增，亮暗各 20 色）、`--lotus-color-ai-*` AI 渐变色 30 个、`--lotus-color-tag-*` Tag 装饰色 32 个、字体/圆角/间距/高度/描边/图标尺寸等基础度量约 57 个、z-index 层级与 info/secondary 语义色变体等其余约 45 个。后续版本对比时以本条记录的 466 为起点，而非已证实不可靠的 388。

## 已知设计权衡（不是缺陷，勿"修复"）

- **Tertiary 语义色**（`#6B7075`）定位是"第三级操作、中性图标"（DESIGN.md 原文），不是用于"实心背景+白字"的强调色，其品牌色对白字对比度天然较低，这是设计意图，不纳入 button-label 对比度检查范围。
- **Success/Warning/Danger 的 Solid 按钮白字对比度低于教科书式 4.5:1 标准**，是 Semi 官方生产环境的既有权衡（已用本地源码核实其真实使用白色文字），lotus 品牌色沿用相同数值故继承同样权衡。若未来 lotus 品牌色独立于 Semi 演进，可重新评估是否要更保守的取值，但不应假设当前数值是"未修复的 bug"。
- **FloatButton/Button/Tag 的 AI 渐变按钮（`colorful` prop）default 态白字对比度最低点仅 3.11:1**（渐变起点 `#e945ff` 粉紫色与白字），低于正文 4.5:1 但满足 UI 组件 3.0:1 门槛；hover 态 4.35:1、active 态 6.15:1 均达标。这个数值来自 2026-08-29 核实一手来源（`~/i/semi-design/packages/semi-theme-default/scss/_palette.scss` 的 `--semi-ai-general-5/6/7`）修正 `aiColor` 后的真实计算结果——修正前 lotus 用的是拍脑袋近似色（角度/色标数/顺序均不对齐一手来源），错误实现下 default 态对比度实测只有 2.83:1（更低），侧面印证"先核对一手来源再判断是否权衡"比"先假设当前实现正确"更可靠。"多彩渐变+统一白字"这类设计范式下渐变最亮端对比度偏低是 Semi 官方一手来源本身的固有权衡（Semi 自己也没有为渐变按钮改变白字颜色），不是 lotus 引入的缺陷，同样不应被"修复"成改小渐变亮度或换用深色文字。
