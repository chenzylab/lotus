# 横切能力 SPEC — 性能基线

> 设计依据：`specs/references/semi-design-articles.md` 「Performance」「PerfBaseline」两节。
> **不复用 Semi 的具体数值**（不同运行时不可比），但复用其方法论：以 INP 为核心指标，明确测试环境与数据规模，建立可追溯的基线记录。

## 适用组件

Phase 4 全部组件（Select/Cascader/TreeSelect/Table 及其虚拟化基础设施）+ Phase 2 的 Toast/Notification（高频调用场景）+ Phase 6 的 AiChatDialogue（流式渲染场景）。其余组件默认不需要建立正式基线，但若开发中主观感受到卡顿，同样应走本流程排查。

## 指标与阈值

- 核心指标：**INP (Interaction to Next Paint)**。
  - < 200ms：合格
  - 200-500ms：需优化
  - \> 500ms：不可接受，视为该组件未完成
- 大数据交互类组件（Select/Tree/TreeSelect/Cascader/Table）以 200ms 为验收分界线，与 Semi 保持一致的方法论（非数值）。

## 测试环境记录规范

每条基线记录必须包含：
- 设备/浏览器（建议固定用一台设备保持可比性，记录型号）
- 运行模式（生产构建，非 dev server）
- 数据规模（节点数/行数）
- 具体操作与耗时（如"面板打开"、"搜索输入响应"、"全选"）
- 记录日期与对应的 lotus 版本/commit

## 基线记录格式

在 `specs/cross-cutting/perf-baseline-records.md`（首次需要时创建）中按组件分节记录，格式参照：

```markdown
### Select — 2026-XX-XX (commit abc1234)
环境：MacBook Pro / Chrome 隐私模式 / production build
数据规模：1 万节点，虚拟化开启

| 操作 | 耗时 (ms) | 判定 |
|---|---|---|
| 面板打开 | 180 | 合格 |
| 搜索输入响应 | 45 | 合格 |
```

## 优化手段清单（复用 Semi 验证过的思路，非代码）

- 优先 CSS 动画而非 JS 动画
- 拍平树形结构 + 虚拟化 + HashMap 映射，避免 O(n) 遍历
- key 生成算法确保 O(1)
- 延迟计算（如省略号截断）到真正需要交互的时刻，而非渲染时立即计算
- 组件卸载时清理所有定时器/监听器（发布订阅 + WeakRef 模式，避免手动到处 `removeEventListener`）
- Ripple 本身是细粒度响应式（非 VDOM diff），部分传统 React 性能问题天然规避，但不代表可以忽视——仍需验证 `track()` 依赖追踪粒度是否过粗（例如整个大对象变化触发过多订阅者更新）

## 验收标准

- [x] 适用组件均有基线记录，记录格式符合上述规范（环境/规模/耗时/判定四要素齐全）——核实发现此前只有 AiChatDialogue、Select/Cascader/TreeSelect 有记录，第6行"适用组件"明确要求的 Table、Toast/Notification 缺失，已实测补齐（Table：1万行虚拟滚动/排序/筛选均合格；Toast/Notification：200次连续触发+销毁循环无退化），四要素齐全，`specs/cross-cutting/perf-baseline-records.md` 现已覆盖全部适用组件
- [x] 任一操作耗时超过 500ms 的场景已修复或有明确的后续优化计划记录（不允许静默忽略）——核实 `perf-baseline-records.md` 全部记录，无任何场景超过 200ms 合格线，自然不存在需要处理的超标项
- [ ] 虚拟化开关的启用阈值（多少条数据以上自动/建议开启虚拟化）已通过实测数据确定，写入组件文档，而非拍脑袋设定——核实发现 Select/Cascader/TreeSelect/Table 组件源码与文档里均未记录任何"多少条以上建议开启虚拟化"的实测阈值，现有基线记录测的都是"已开启虚拟化"场景本身的性能，从未测过"不开虚拟化时不同数据规模的性能拐点"来确定这个阈值。这是真实缺口，需要专门的一轮测量（不同规模下不开虚拟化的耗时曲线），工作量独立于本次基线补齐，留待后续安排
