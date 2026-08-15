---
name: theme-tokens
description: 新增/修改 Design Token、评估组件是否需要新语义变量、或校验主题变更影响面时使用。对照 specs/cross-cutting/theme-tokens.spec.md 的命名规范与验收标准执行。
---

# theme-tokens

## 何时使用

- 新组件引入了现有 Token 体系未覆盖的视觉需求（新的语义色、新的圆角级别等）
- 修改已发布的 Token 变量（评估 semver 影响）
- 组件开发中需要判断"这个颜色/间距该用哪个变量"

## 操作前必读

`specs/cross-cutting/theme-tokens.spec.md`（命名规范、色彩算法要求、AI 色彩变量清单、四层分级模型、完整分类清单、已知设计权衡）。本 SKILL 是该 SPEC 的操作手册，不重复内容，只给执行步骤。

**开工前的最重要一步**：如果是从零设计/大幅扩展 Token 体系（不是单个变量的小修小补），先完整读 `~/i/semi-design/packages/semi-theme-default/scss/{global.scss,variables.scss}` 全文，而不是只看 `DESIGN.md` 摘要。Phase 1 曾因只读摘要导致 Token 体系缺失近一半分类（浅版三态、5 层背景、4 层文字、9 级间距、Z-index、字重、控件高度、描边宽度等），被迫推翻重写，详见 `theme-tokens.spec.md` 开头的记录。**Token 是先于组件的基础设施，必须一次设计完整，不要以"当前组件够用"为由零散补丁**——每次为了打样一个新组件才发现缺变量、临时加一个，会导致后来者不知道哪些是完整设计、哪些是临时凑的，且会有变量重复定义或语义不一致的风险。

## 新增变量前的判断步骤

1. 先查 `specs/cross-cutting/theme-tokens.spec.md`「完整分类清单」，确认这个需求是否已有归属分类（多数情况下有，只是還没被消费）。
2. 再查 `packages/tokens/dist/tokens.css`（或源文件）是否已有语义相近的变量，`grep` 关键词确认，避免重复定义。
3. 判断该值属于哪一层：
   - 如果是新的品牌色/色相 → L4 基础色阶（需要跑一遍色彩算法生成 0-9 十级）
   - 如果是新的语义角色（如新增一个"信息强调色"）→ L3 全局语义变量，引用已有 L4 色阶
   - 如果只是某个组件的特定尺寸/间距，其他组件不会用到 → L2 组件级变量
4. 命名遵循 `--lotus-{层级前缀}-{语义}[-状态后缀]`，状态后缀限定为 `-hover`/`-active`/`-disabled`/`-focus`。

## 色彩对比度校验步骤

新增或修改颜色类变量后：
1. 用 `packages/tokens/src/contrast.ts` 的 `contrastRatio` 函数实测计算该颜色与其典型使用背景的对比度比值，**不要凭肉眼判断，也不要假设"应该达标"而跳过实测**。
2. **按正确的 WCAG 场景分类选阈值，不要一律套用 4.5:1**：正文文本 ≥ 4.5:1；大文本/UI 组件边界 ≥ 3:1；实心色块按钮文字场景**没有统一硬性阈值**——Semi 官方生产环境的 Warning/Danger 白字对比度实测仅 2.42/3.73（已用本地源码核实其确实使用白色文字），这是已知的行业级权衡，不是缺陷。
3. 若某数值确实不达标且找不到"这是设计权衡"的证据支持，才调整色阶取值（更深/更浅一档），而不是先调整颜色再假装测试从未失败过。
4. 亮色、暗色模式分别校验，两套都要有独立实测。
5. 测试写法参考 `packages/tokens/src/contrast.test.ts`：能设定硬性阈值的场景用 `toBeGreaterThanOrEqual`，权衡未定的场景用 `console.log` 记录实测值 + 仅挡"完全不可辨识"的下限，不要为了让测试变绿而弱化断言的实际意义。

## AI 色彩变量（Phase 1 起需要）

新组件涉及 AI 主题变体（AIButton/AIIcon/AITag/AIFloatButton 或 Phase 6 AI 组件）时，消费既有的 `--lotus-color-ai-general`/`--lotus-color-ai-purple`/`--lotus-color-ai-background-top`/`--lotus-color-ai-background-bottom` 及其状态变体，不要为单个组件另起一套 AI 配色。如果这些变量确实不满足需求，先评估是否该扩展现有 AI 变量集，而非在组件内联硬编码。

## 破坏性变更处理

重命名或删除已发布的 Token 变量视为 breaking change：
1. 先 `grep -r "变量名" packages/ripple/src` 确认影响面（哪些组件在用）。
2. 更新所有消费方到新变量名/新方案。
3. 在对应 changeset 中标注 major，说明旧变量名的迁移路径。

## 验收标准

对照 `specs/cross-cutting/theme-tokens.spec.md` 「验收标准」小节逐项自检，不要省略任何一项直接视为完成。
