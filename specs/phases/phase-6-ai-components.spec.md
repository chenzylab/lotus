# Phase 6 — AI 智能化组件

> 依赖：Phase 5 完成（Sidebar、Chat 基础壳、ConfigProvider 均已就绪）。
> 组件清单见 `specs/component-inventory.md` 「Phase 6」小节（AiChatDialogue/AiChatInput/AiComponent）。
> 设计依据：`specs/references/semi-design-articles.md` 「AI」一节的五大设计原则与四阶段交互模型（路径引导 → 输入 → 过程感知与控制 → 结果呈现与控制 → 循环反馈）。

## 目标

在 Phase 5 的 Chat 基础壳之上，实现真正的 AI 交互体验：流式响应展示、过程可中断、结果可复核/重新生成、用户反馈闭环（点赞/点踩/纠错）。这是全项目唯一一个「设计原则先于技术实现」的阶段——开工前必须先能讲清楚每个子组件对应五大原则中的哪一条，再落地代码。

## 范围

- **AiChatInput**：意图可表达原则的落地——除基础文本输入外，支持提示模板（快捷指令）、多模态附件（如支持图片/文件），输入态与发送态的过渡动画走 CSS。
- **AiChatDialogue**：核心难度在于**流式内容渲染**——响应逐字/逐块到达时的增量渲染，需要 Foundation 层设计一个「流式文本累积」状态机（不能每个 token 到达都触发整个消息树重渲染，需评估 Ripple 细粒度响应式模型下如何做到只更新变化的文本节点）。同时要支持过程中断（用户点击"停止生成"）、结果操作（复制/重新生成/调整语气），以及消息级反馈（点赞/点踩/收藏）。
- **AiComponent**：官网收录的通用 AI 交互组件集合，视 Semi 实际实现内容（本项目未详细拆解，需要在开工前先用 `Explore` 或 `WebFetch` 核实其具体 API 面，避免凭猜测实现）。

## 依赖 Skill

`component-authoring`、`foundation-authoring`（流式状态机是本阶段设计难点）、`theme-tokens`（AI 渐变色变量的实际消费场景，验证 Phase 1 预留的设计是否够用）、`a11y-audit`（流式内容对屏幕阅读器的适配是特殊难点——内容持续变化时如何避免过度打断朗读，需要 `aria-live` 策略设计）、`testing`

## 验收标准

- [x] 清单文件中 Phase 6 全部条目勾选，满足 DoD（AiChatDialogue/AiChatInput 完整交付，AiComponent 核实为非独立组件+`colorful` 补齐，见下方核实结论）
- [x] 开工前产出一份简短映射表（AiChatInput/AiChatDialogue/AiComponent 的具体子功能 → 对应五大设计原则中的哪一条），作为实现依据存档在本 SPEC 文件末尾（**注：本表实际是开发完成后补记，非开工前产出——流程上的欠账，如实记录**）
- [ ] **未完成**：AiChatDialogue 的流式渲染缺少正式性能验证——`streamingResponseToMessage`/`streamingChatCompletionToMessage` 归约器本身有单测覆盖正确性，但没有按 `perf-baseline` skill 方法论模拟高频（如每 50ms 一个 token）追加场景并记录 INP/帧率数据，这是本 Phase 的真实欠账
- [x] 流式生成过程可通过用户操作中断（"停止生成"按钮）：AiChatInput 的 `generating` 受控 prop + `onStopGenerate` 回调已实现，e2e 覆盖按钮切换；Foundation 层不持有网络请求生命周期（中断后的悬挂任务清理责任在消费方，Foundation 状态本身无残留）
- [x] 消息反馈操作（点赞/点踩/纠错/收藏）的交互状态有 Foundation 单测：`toggleAiLike`/`toggleAiDislike` 互斥切换、`toggleAiEditing`/`commitAiEdit` 均有对应测试（`foundation.test.ts`）；"收藏"Semi 原生无此字段，未实现
- [ ] **未完成**：流式内容更新时的屏幕阅读器体验未经过正式 `a11y-audit` skill 检查——`index.tsrx:211` 已加 `aria-live="polite"`，但这是实现时的常规无障碍处理，不是走完整 audit 流程验证过"逐字更新是否过度打断朗读"，这是本 Phase 的真实欠账
- [x] AiComponent 的实现范围已核实自 Semi 官方文档/源码（而非猜测），核实过程与结论记录在本 SPEC（见下方「AiComponent 核实结论」）

## 设计原则映射表

| 子组件/功能 | 对应设计原则 | 具体实现要点 |
|---|---|---|
| AiChatInput 提示模板/技能选择 | 意图可表达 | `skillHotKey` 触发技能面板，选中后插入 `skillSlot` chip；`renderTemplate` 覆盖点展开模版面板，一键填充预设文案 |
| AiChatInput 多模态附件 | 意图可表达 | 复用 Upload 组件真实上传流程，附件列表随发送载荷（`AiInputMessageContent.attachments`）一并交出 |
| AiChatDialogue 流式渲染 | 过程感知与控制 | `streamingResponseToMessage`/`streamingChatCompletionToMessage` 按 `sequence_number` 顺序处理+无序缓冲+`MAX_GAP` 容错，供外部 SSE 处理器增量调用；reasoning 块默认展开条件 `status !== 'completed'`，让用户能看到"正在思考"过程 |
| AiChatDialogue 工具调用/MCP 交互块 | 过程感知与控制 | 状态图标+折叠+JSON 格式化参数输出+`call_id`+MCP server 标签，复用 CodeHighlight 做高亮，让"AI 在做什么"对用户可见可核查 |
| AiChatDialogue 停止生成 | 过程感知与控制 | AiChatInput 的 `generating` 受控 prop 驱动"停止生成"按钮，`onStopGenerate` 回调交给消费方中断底层请求（Foundation 层不持有网络请求生命周期，只做 UI 态切换） |
| AiChatDialogue 消息编辑/重新生成 | 结果呈现与控制 | `editing`+`onMessageEdit`+`messageEditRender` 覆盖点，用户可修正后重新提交 |
| AiChatDialogue 点赞/点踩 | 循环反馈 | Foundation 状态机 `toggleAiLike`/`toggleAiDislike` 互斥切换，为消费方接入真实反馈上报留出纯状态管理层 |
| AiChatDialogue hint 建议提示 | 路径引导 | 空状态下展示预设 hint，点击直接追加一条用户消息，降低"不知道该问什么"的启动门槛 |

## AiComponent 核实结论

Semi 官方源码/文档中**不存在**名为 `AiComponent`/`AIComponent` 的独立组件。`~/i/semi-design/content/ai/aiComponent/index.md` 是 AI 分类的文档总览页（frontmatter `title: AIComponent 能力介绍`），不是组件 API 文档——`packages/semi-ui` 下 76 个组件目录里没有对应实体，`content/` 与 `packages/semi-ui` 分属文档站与组件包两个完全不同的目录树。chenzy.design 同样只有一篇导览 markdown（`packages/docs/.../guide/ai-component/+page.md`），没有独立组件文件，两个姊妹项目结论一致。

该文档把 AI 能力拆成三块，逐条核实：

1. **AI Token**（20 个渐变色变量）——Phase 1 已实现于 `packages/tokens/src/static-tokens.ts` 的 `aiColor`。
2. **AI Icon**（约 30 个 svg）——属于图标移植范围，已完成。
3. **Button/Tag/FloatButton 的 `colorful` prop**——`FloatButton.colorful` Phase 1 已实现；`Button.colorful`/`Tag.colorful`+`gradient` 此前遗漏，本次（Phase 6 收尾）补齐，纯 prop→CSS 映射，无 Foundation 状态机，测试并入既有 `e2e/basic/button.spec.ts`/`e2e/show/tag.spec.ts`。
4. **AIChatInput/AIChatDialogue/Sidebar**——均为真实独立组件，已在本 Phase/Phase 5 完成。
5. **AIChatBox**——Semi 官网原文写"未来将支持"，目前不存在，纯规划占位，lotus 不实现。

结论：component-inventory.md 的 "AiComponent" 条目已改写为上述核实结论 + `colorful` 补齐记录，不作为独立组件立项。
