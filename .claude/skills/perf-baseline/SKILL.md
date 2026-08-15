---
name: perf-baseline
description: 为大数据量组件（Table/Tree/Select/Cascader/TreeSelect 及高频调用的 Toast/Notification、流式渲染的 AiChatDialogue）建立或校验性能基线时使用。对照 specs/cross-cutting/perf-baseline.spec.md 的方法论与记录格式执行。
---

# perf-baseline

## 何时使用

- 组件涉及大数据虚拟化（Table/Tree/Select/Cascader/TreeSelect）
- 组件被高频调用/挂载卸载（Toast/Notification）
- 组件有持续/高频更新场景（AiChatDialogue 流式渲染）
- 主观感受到某组件卡顿时，即使不在上述名单也应走此流程排查

## 核心指标

**INP (Interaction to Next Paint)**：
- < 200ms 合格
- 200-500ms 需优化
- \> 500ms 不可接受，组件不能视为完成

## 测量步骤

1. 用生产构建（非 dev server），固定测试设备/浏览器（记录型号，同一设备保持跨版本可比）。
2. 准备目标数据规模（如"1 万节点"），优先测试组件文档/Phase SPEC 中要求的规模基准。
3. 用浏览器 DevTools Performance 面板或 Playwright 的 `page.evaluate` + Performance API 记录关键操作（面板打开、搜索输入、全选等）的耗时。
4. 按 `specs/cross-cutting/perf-baseline.spec.md` 的记录格式写入 `specs/cross-cutting/perf-baseline-records.md`（首次使用需创建），环境/规模/耗时/判定四要素齐全。

## 超标处理

- 耗时 200-500ms：定位具体瓶颈（不必要的重复计算/未虚拟化的大列表/未做的防抖节流），参照 `specs/references/semi-design-articles.md` Performance 一节的优化手段清单排查。
- 耗时 > 500ms：视为组件未完成，必须优化到合格线才能在 Phase SPEC 清单打勾，不允许"先记录问题，后续再修"的方式蒙混过关（除非用户明确同意延后处理并记录为已知问题）。
- 常见根因：未虚拟化、树形结构未拍平、key 生成算法非 O(1)、JS 动画未替换为 CSS 动画、组件卸载未清理定时器/监听器导致的内存增长影响后续交互。

## Ripple 特有的排查点

Ripple 是细粒度响应式（非 VDOM diff），传统 React 的"无谓 re-render"问题较少见，但需要额外检查：
- `track()` 的依赖粒度是否过粗（整个大对象作为一个 track 单元，导致对象任意字段变化都触发所有订阅者更新，而非只更新真正相关的部分）
- 大列表渲染是否为每一项创建独立的细粒度响应式单元（而非整个列表作为一个大 track 单元重新计算）

## 验收标准

对照 `specs/cross-cutting/perf-baseline.spec.md` 「验收标准」小节：基线记录格式完整、无超标未处理项、虚拟化启用阈值有实测数据支撑（不是拍脑袋设定）。
