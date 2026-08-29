# Phase 5 — 全局配置 + 富媒体/工具类

> 依赖：Phase 4 完成不是硬性前置（本阶段组件与 Phase 4 技术栈交叉较少），但建议顺序执行以保持团队/Agent 对项目全貌的连续认知。
> 组件清单见 `specs/component-inventory.md` 「Phase 5」小节。

## 目标

交付两类内容：（1）全局配置层 ConfigProvider/Locale，这是让此前所有组件真正具备「主题切换」「语言切换」能力的收口组件——**必须等大部分组件已实现后再做，因为需要真实组件去验证 Provider 的上下文注入是否覆盖完整**；（2）富媒体与工具类组件（CodeHighlight/MarkdownRender/JsonViewer/Chat/AudioPlayer/VideoPlayer/Lottie/DragMove/HotKeys/Sidebar）。

## 范围

- **ConfigProvider**：使用 Ripple 的 `Context` API（`new Context(defaultValue)` + `set`/`get`）向组件树注入主题、语言、组件默认 props 等全局配置。这是对 Phase 0-4 所有组件的一次回归验证——ConfigProvider 落地后必须抽查至少 5 个不同阶段的组件，确认它们能响应 Context 变化（例如切换主题色后无需刷新页面即时生效）。
- **Locale**：对接 `@lotus/locale` 包，本组件不是独立视觉组件，而是 ConfigProvider 的语言子系统。
- **CodeHighlight/MarkdownRender/JsonViewer**：均属于「重内容渲染，轻交互状态」类型，评估是否有可直接消费的底层库（如语法高亮/Markdown 解析库）而不必自研解析器，重点工作在于把渲染结果套上 lotus 的 Token 样式与交互外壳（复制按钮、折叠等）。
- **Chat（基础版）**：本阶段只做消息列表渲染 + 输入框的基础壳层，不做 Phase 6 才涉及的 AI 过程感知/流式响应 UI。
- **AudioPlayer/VideoPlayer**：媒体控件状态机（播放/暂停/进度/音量），是继 Carousel 之后第二个需要「播放状态机」Foundation 的组件，评估是否可以和 Carousel 共享部分状态机模式（不强制，视实际重合度判断）。
- **Lottie**：动画播放控件，评估依赖的动画运行时是否与 Ripple 渲染模型冲突（Lottie 通常直接操作 Canvas/SVG DOM，需要确认与 Ripple 的响应式更新不产生冲突写入）。
- **DragMove/HotKeys**：纯交互能力型组件（不一定有默认视觉），是「行为组件」而非「展示组件」，Foundation 层价值最高、Adapter 层最薄。
- **Sidebar**：通用容器组件，本阶段作为独立可复用侧边栏容器交付，Phase 6 的 AI 场景会直接复用它。

## 依赖 Skill

`component-authoring`、`foundation-authoring`、`theme-tokens`（ConfigProvider 的主题切换是本阶段验证重点）、`i18n-locale`（Locale 收口）、`a11y-audit`（HotKeys 与已有快捷键的冲突检测）、`testing`

## 验收标准

- [ ] 清单文件中 Phase 5 全部条目勾选，满足 DoD
- [x] ConfigProvider 切换主题色后，抽查的 5 个既有组件（建议覆盖 Button/Input/Select/Modal/Table 各一次）在不刷新页面的前提下视觉即时更新，Playwright 用例验证——重新核实后发现 Semi 的 ConfigProvider 本身不承载主题能力（暗色模式是脱离 ConfigProvider 的全局属性操作），这条标准描述的是 lotus 自己想要的能力而非照搬 Semi，本次新增 `ConfigProvider.mode` prop 实现并验证
- [x] ConfigProvider 切换语言后，Form 校验文案、DatePicker 月份名称等此前依赖 `@lotus/locale` 的组件同步更新——`e2e/other/config-provider.spec.ts` 已有对应测试（切换 locale 后 Form 校验错误文案实时更新；DatePicker/TimePicker 的月份格式/星期文案/小时单位跟随 locale 切换），纯文档滞后未勾选
- [x] DragMove/HotKeys 的 Foundation 层可独立于任何具体组件单测（验证其「纯交互能力」定位是否真正做到框架/组件无关）——核实两者的 `foundation.ts` 均不依赖 `document`/`window` 等 DOM 全局对象，各自有独立 `foundation.test.ts`（HotKeys 16 条、DragMove 13 条），纯文档滞后未勾选
- [x] AudioPlayer/VideoPlayer 的播放状态机有 Foundation 单测，覆盖切换播放源时旧的定时器/事件监听被正确清理——核实两者播放状态机完全委托给原生 `<audio>`/`<video>` 元素事件（JSX 属性绑定 `onTimeUpdate` 等，非手写 `addEventListener`），"切换播放源"场景下浏览器自己处理旧监听器，Foundation 本身不持有网络/媒体层监听器，这部分 spec 字面要求的场景不存在。但核实组件层时发现 VideoPlayer 确实有一个真实缺口：`controlsHideTimer`（控制条自动隐藏的防抖 `setTimeout`）此前只在下次调用时被 `clearTimeout`，组件卸载时若恰好有一个尚未触发的定时器完全没有清理逻辑，是与 Carousel autoPlay 定时器同一类"卸载时遗漏清理"的问题，已补上对应 `effect` cleanup 并用调用栈拦截的方式写 e2e 验证，`--repeat-each=5` 稳定通过；`fullscreenchange` 监听器已有正确 cleanup
- [x] Lottie 组件卸载时动画实例被销毁，无残留渲染循环（Playwright 验证长时间停留无内存增长趋势，或至少确认销毁方法被调用）——核实驱动 lottie-web 实例的两处 `effect` 均已在 cleanup 里正确调用 `animation.destroy()`，是真实代码早就实现好、只是从未有 e2e 验证过这条卸载路径的情况；新增测试验证卸载后 DOM 容器随之移除、重新挂载后能正常渲染新实例（排除"表面卸载但底层状态已损坏"的假阳性），`--repeat-each=5` 稳定通过
