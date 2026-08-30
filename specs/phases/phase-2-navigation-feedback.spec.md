# Phase 2 — 导航 + 反馈

> 依赖：Phase 1 已完成（Icon/Button/Typography 等基础组件可复用）。
> 组件清单见 `specs/component-inventory.md` 「Phase 2」小节。

## 目标

交付页面级导航组件（Tabs/Breadcrumb/Steps/Pagination/Anchor/BackTop/Navigation）与用户反馈组件（Banner/Notification/Toast/Popconfirm/Progress/Skeleton/Spin/Result）。这批组件的共同特点是**大量涉及焦点管理与瞬时状态（弹出/消失、进度变化）**，是 `a11y-audit` skill 中「焦点归还」「动画安全性」条款的主要落地对象。

## 范围

- **导航类**：Tabs/Breadcrumb/Steps/Pagination 是纯受控展示 + 简单状态；Anchor/BackTop 涉及滚动监听（Foundation 层需要抽象「滚动位置计算」为框架无关逻辑，Adapter 负责绑定真实 scroll 事件）；Navigation 是组合型容器（菜单 + 折叠 + 路由高亮），复杂度接近 Form。
- **Tree（导航基础版）**：本阶段只交付静态展示 + 基础展开/收起，不做拖拽排序、虚拟化、搜索高亮（这些留给 Phase 4 与 Table/Select 系列一起处理，因为都要复用同一套「大数据虚拟化」Foundation 能力，此处提前做等于返工）。
- **反馈类**：Toast/Notification 是全局单例式组件（需要一个类似 Semi `Toast.info()` 的命令式 API，同时保留声明式用法），这是本阶段唯一需要设计「非 Props 驱动」API 的组件，需要专门评估 Ripple 下如何实现命令式渲染（可能需要一个独立的挂载容器 + `RippleObject` 管理的队列状态）。
- **Popconfirm**：复用 Phase 3 才排期的 Popover 定位逻辑——**存在前向依赖**，实现时先抽取一个通用的「浮层定位」Foundation（`packages/foundation/base/popupPosition.ts`），本阶段和 Phase 3 共用，避免 Phase 3 重做。**自研实现，不依赖 Floating UI / Popper.js 等第三方定位库**（见 AGENTS.md「基础能力自研」条款）；可参考此类库公开的碰撞检测与自动翻转算法思路（可用空间计算、首选位置降级序列）重新实现。

## 依赖 Skill

`component-authoring`、`foundation-authoring`、`a11y-audit`（焦点管理、动画闪烁频率）、`perf-baseline`（Toast/Notification 高频调用场景下的内存泄漏，参照 Semi Performance 文章中 WeakRef 事件委托的思路）、`testing`

## 验收标准

- [x] 清单文件中 Phase 2 全部条目勾选，满足 DoD——核实 `specs/component-inventory.md` Phase 2 小节全部 15 个组件均已勾选（Tabs/Breadcrumb/Steps/Pagination/Anchor/BackTop/Navigation/Tree/Banner/Notification/Toast/Popconfirm/Progress/Skeleton/Spin）
- [x] Toast/Notification 同时支持命令式 API（`toast.success('message')`）与组件卸载后自动清理定时器（无内存泄漏，需要 Playwright 测试重复挂载/卸载 100 次后无残留 DOM 节点或监听器）——核实两者采用单例懒挂载容器设计（`ensureMounted()` 只在首次调用时创建 div，后续 `open()` 复用同一容器），"挂载/卸载"的真实含义是 `destroyAll()` 卸载单例容器+下次 `open()` 重新走 `ensureMounted` 创建新容器，不是每次调用都新建/销毁一个容器；新增测试循环 100 次"触发+destroyAll"验证每次循环后 DOM 干净、挂载容器不累积，且循环后再次调用仍能正常工作（排除"表面 count 为 0 但底层状态已损坏"的假阳性）
- [x] Anchor/BackTop 的滚动监听逻辑在 Foundation 层可单测（mock 一个满足 `Adapter` 接口的假宿主，不依赖真实 DOM `scroll` 事件）——核实两者均有独立 `foundation.test.ts`：Anchor 的 `flattenLinks`/`resolveActiveLink` 是纯数据结构测试；BackTop 的 `handleScroll`/`handleClick` 接收数值做判断，不依赖真实 `scroll` 事件，纯文档滞后未勾选
- [x] 所有可关闭的浮层类组件（Popconfirm/Notification 等）关闭后焦点归还到触发元素，Playwright 用例验证 `document.activeElement`——Popconfirm 已有对应 e2e 测试（`toBeFocused` 验证）；核对 Semi 一手来源确认 Notification 完全不做任何焦点操作（`grep focus()` 零命中），这类非模态通知本就不该抢焦点（ARIA `role="alert"`/`role="status"` 的既定语义），"焦点归还"这个概念对它不适用，不是遗漏
- [x] 进度类动画（Progress/Skeleton loading 态）使用 CSS 动画实现，不使用 JS `requestAnimationFrame` 手动计算（除非有精确到帧的交互需求），并且闪烁频率 < 3 次/秒——核实 Skeleton loading 态本就用 `@keyframes` 纯 CSS 实现，符合要求；但 Progress 组件曾用自研 `animateValue`（内部基于 `requestAnimationFrame`）逐帧计算 `displayPercent` 中间态，是真实违反本条要求的缺陷。核对 Semi 一手来源（`progress.scss` 只有 `transition: width`/`transition: stroke-dashoffset`，没有任何 JS 帧驱动逻辑）确认纯 CSS 方案是标准做法，已重构：`displayPercent` 直接等于 `percent` 本身（不再是可变插值中间态），数值变化的视觉过渡改由 `.lotus-progress-track-inner` 的 `width`/`height` transition 与 `.lotus-progress-circle-ring-inner` 的 `stroke-dashoffset` transition 驱动；新增 `motion={false}` 时通过 `.lotus-progress-no-motion` 类将上述 transition 的 `transition-duration` 置零来禁用动画。新增 e2e 用例验证 transition 属性真实生效（真机验证：`motion=true` 时宽度从旧值渐进过渡到新值，`motion=false` 时 50ms 内已到达目标值无渐变过程）
- [x] 抽取的通用浮层定位 Foundation（`popupPosition.ts`）有独立 Vitest 单测，覆盖视口边缘碰撞检测（弹层超出视口时自动翻转方向）——核实实际文件名是 `packages/foundation/src/base/floating-position.ts`（spec 范围章节记录过改名为 `floating-position.ts`，这条验收标准本身遗留了旧文件名，纯文档滞后未同步），`floating-position.test.ts` 的 `autoAdjustOverflow 溢出翻转` 测试块 5 条用例覆盖上/下/左/右四个方向的溢出翻转、双向空间都不足时保留首选方向、`autoAdjustOverflow=false` 时不翻转，共 9 条测试全部通过
