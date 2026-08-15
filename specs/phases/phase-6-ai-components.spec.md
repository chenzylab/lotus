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

- [ ] 清单文件中 Phase 6 全部条目勾选，满足 DoD
- [ ] 开工前产出一份简短映射表（AiChatInput/AiChatDialogue/AiComponent 的具体子功能 → 对应五大设计原则中的哪一条），作为实现依据存档在本 SPEC 文件末尾
- [ ] AiChatDialogue 的流式渲染有性能验证：模拟高频（如每 50ms 一个 token）追加内容场景下，不产生明显掉帧，参照 `perf-baseline` skill 的方法论记录 INP 或帧率数据
- [ ] 流式生成过程可通过用户操作中断（"停止生成"按钮），中断后 Foundation 状态机进入明确的终态，不留下悬挂的异步任务
- [ ] 消息反馈操作（点赞/点踩/纠错/收藏）的交互状态有 Foundation 单测
- [ ] 流式内容更新时的屏幕阅读器体验经过 `a11y-audit` skill 的 `aria-live` 检查，不会因为逐字更新导致朗读被过度打断
- [ ] AiComponent 的实现范围已核实自 Semi 官方文档/源码（而非猜测），核实过程与结论记录在本 SPEC

## 待补充：设计原则映射表

> 开工前填写，不要留空直接开始编码。

| 子组件/功能 | 对应设计原则 | 具体实现要点 |
|---|---|---|
| （待填写） | | |
