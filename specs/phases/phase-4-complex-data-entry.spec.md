# Phase 4 — 复杂数据录入与展示

> 依赖：Phase 3 已完成（浮层定位 Foundation 可复用于 Select/Cascader/DatePicker 等下拉面板）。
> 组件清单见 `specs/component-inventory.md` 「Phase 4」小节。这是全项目技术难度最高、`perf-baseline` skill 使用最密集的阶段。

## 目标

交付大数据量、高交互复杂度的组件：Select/Cascader/TreeSelect/AutoComplete/Table，以及独立的复杂输入控件 DatePicker/TimePicker/Slider/Rating/ColorPicker/Transfer/Upload/TagInput/PinCode。

## 范围

- **虚拟化基础设施先行**：Select/Cascader/TreeSelect/Table 共享同一套「虚拟滚动」Foundation（`packages/foundation/base/virtualList.ts`），必须先实现并单测这一层，再开始四个组件各自的 Adapter，避免四份重复实现。**自研实现，不依赖 `react-window`/`@tanstack/virtual` 等第三方虚拟化库作为运行时依赖**（见 AGENTS.md「基础能力自研」条款）；可阅读此类库的公开算法思路（可见区间计算、动态高度测量与缓存、滚动锚定防抖）作为设计参考，并参照 `specs/references/semi-design-articles.md` Performance 一节的拍平数据结构 + HashMap 映射思路重新实现。
- **Select/Cascader/TreeSelect/AutoComplete**：共用浮层定位（来自 Phase 3）+ 虚拟化列表（本阶段新增）。级联/树形选择的核心难度在「已选值与树节点展开状态的双向同步」，应完全在 Foundation 层实现并单测，不依赖真实渲染验证。
- **Table**：本项目复杂度最高的组件，涵盖排序、筛选、固定列、树形数据、虚拟化。建议拆成多个子 SPEC 或至少在实现顺序上分「基础表格 → 排序筛选 → 固定列 → 树形数据 → 虚拟化」五个里程碑，每个里程碑单独验证再叠加下一个，不要一次性实现。
- **DatePicker/TimePicker**：复用 Phase 3 Calendar 的日期计算 Foundation。
- **Slider/Rating/ColorPicker**：数值型输入，重点是拖拽手势的 Foundation 抽象（指针位置 → 数值的纯函数转换），沉淀为可复用的 `packages/foundation/base/dragTracker.ts`（自研，可参考 `interact.js` 等库的指针事件归一化/边界约束思路，不引入其作为依赖），与键盘方向键操作的等价支持。
- **Transfer/Upload/TagInput/PinCode**：中等复杂度，Upload 需要额外处理文件类型/大小校验、上传进度、断点续传（若要求）等异步状态机。

## 依赖 Skill

`component-authoring`、`foundation-authoring`、`perf-baseline`（本阶段每个虚拟化组件必须建立基线，不可省略）、`a11y-audit`（拖拽类组件的键盘等价操作是常见遗漏点）、`i18n-locale`（DatePicker/TimePicker 的格式化）、`testing`

## 验收标准

- [ ] 清单文件中 Phase 4 全部条目勾选，满足 DoD
- [x] `virtualList.ts` Foundation 有独立 Vitest 单测（滚动位置 → 可见区间计算），且 Select/Cascader/TreeSelect/Table 四者（以及 Transfer，共 5 者）的虚拟化代码确认复用同一实现（非各自复制，`grep calcVirtualRange` 验证）——**「条目高度不固定场景」这条按当前架构不适用，如实修正**：`base/virtual-list.ts` 的实现从一开始就明确设计为固定行高（源码注释：对齐 Semi react-window `FixedSizeList` 与 chenzy.design 参考实现两方都验证过的合理最小范围），`itemHeight` 是单一数值而非按项取值的函数，本质上不支持"条目高度不固定"这个场景；Table 虚拟化同样限定"仅在无 `expandedRowRender`（展开行任意高度，与固定行高假设冲突）时生效"，是同一个架构决策的延伸。这条验收标准的字面要求与既定设计相悖，不应勉强造一个测不出来的测试，故如实记录为"不适用"而非留空
- [x] Select/Cascader/TreeSelect 均建立性能基线记录（参照 `specs/cross-cutting/perf-baseline.spec.md` 的记录格式），至少覆盖 1 万节点规模下的面板打开、搜索输入两个场景，INP 数据留痕——核实过程中发现 Select 组件本身缺少 Semi 对齐的 `filter` 搜索能力（`filterOption`/`onSearch`/`searchPosition` 均不存在），已按一手来源（`semi-foundation/select/foundation.ts`）补齐 `filter`/`searchPosition`（trigger/dropdown 两态）/`searchPlaceholder`/`onSearch`，Foundation 单测 + e2e + 文档站 demo + ego-browser 真机验证齐全后再测性能，三者 1 万节点面板打开/搜索响应均在 11~18ms 区间，远低于 200ms 合格线，详见 `specs/cross-cutting/perf-baseline-records.md`
- [ ] Table 按里程碑逐项验收，每个里程碑（基础/排序筛选/固定列/树形/虚拟化）有独立的验收记录，不允许「表格能跑」就笼统视为完成
- [x] Select/Cascader/TreeSelect 的已选值与展开状态同步逻辑，有测试覆盖至少「异步加载子节点后自动展开」「批量选中父节点级联选中/取消子节点」两个场景——核实后澄清：「异步加载后自动展开」这段编排逻辑（`loadData().then()` 里连续调用 `handleLoadEnd`+`handleExpand`）本身写在 Cascader/TreeSelect 的 Adapter 层（`index.tsrx`），不是 Foundation 纯函数，不适合硬造一个 Foundation 方法只为满足"要有 Foundation 单测"的字面要求；`handleExpand`/`handleLoadStart`/`handleLoadEnd` 各自已有独立 Foundation 单测，组合行为由现有 e2e「懒加载」用例间接但确凿验证（断言子节点在加载完成后确实可见/新增列，这依赖 `expandedKeys` 门控，若未自动展开断不会渲染）。「级联选中/取消」此前只覆盖了勾选方向（父→子）和叶子节点自身取消，缺失"取消勾选父节点后子孙同步取消"这一半，已在 Cascader/TreeSelect 两个 Foundation 补齐对应单测
- [x] Slider/Rating/ColorPicker 均可通过键盘方向键完成等价于拖拽的操作，Playwright 用例覆盖——核实发现三者核心方向键此前均已有基础覆盖，但存在维度缺口：ColorPicker 只测过 SV 面板/色相条的单方向，缺 SV 垂直轴（ArrowUp/ArrowDown）与透明度滑条；Slider 缺 PageUp/PageDown、range 模式双手柄键盘操作、vertical 模式键盘语义（三者 Foundation 层均已有单测，只是 e2e 未覆盖）；Rating 缺 allowHalf 开启时键盘按 0.5 步进（此前只测过鼠标点击半星）。已逐项补齐 e2e 用例
- [x] Upload 的异步状态机（选择文件/上传中/成功/失败/取消）有 Foundation 单测，覆盖并发多文件上传时单个文件失败不影响其他文件的场景——`handleProgress`/`handleSuccess`/`handleError` 均按 `uid` 定位单项、`[...fileList]` 浅拷贝替换，设计上天然隔离，新增测试显式断言三个并发文件中一个失败/一个进度更新/一个成功互不干扰
- [ ] DatePicker/TimePicker 的日期/时间格式化输出符合当前 locale（`@lotus/locale`），有至少两种 locale 的对比测试
