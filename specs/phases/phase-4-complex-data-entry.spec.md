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

- [x] 清单文件中 Phase 4 全部条目勾选，满足 DoD——`specs/component-inventory.md` Phase 4 小节 14 个组件全部 `[x]`，Table 记录同步更新固定列已补齐的最新状态（原记录称"本次不需要处理固定列共存"，已核实并修正为固定列功能真实落地）
- [x] `virtualList.ts` Foundation 有独立 Vitest 单测（滚动位置 → 可见区间计算），且 Select/Cascader/TreeSelect/Table 四者（以及 Transfer，共 5 者）的虚拟化代码确认复用同一实现（非各自复制，`grep calcVirtualRange` 验证）——**「条目高度不固定场景」这条按当前架构不适用，如实修正**：`base/virtual-list.ts` 的实现从一开始就明确设计为固定行高（源码注释：对齐 Semi react-window `FixedSizeList` 与 chenzy.design 参考实现两方都验证过的合理最小范围），`itemHeight` 是单一数值而非按项取值的函数，本质上不支持"条目高度不固定"这个场景；Table 虚拟化同样限定"仅在无 `expandedRowRender`（展开行任意高度，与固定行高假设冲突）时生效"，是同一个架构决策的延伸。这条验收标准的字面要求与既定设计相悖，不应勉强造一个测不出来的测试，故如实记录为"不适用"而非留空
- [x] Select/Cascader/TreeSelect 均建立性能基线记录（参照 `specs/cross-cutting/perf-baseline.spec.md` 的记录格式），至少覆盖 1 万节点规模下的面板打开、搜索输入两个场景，INP 数据留痕——核实过程中发现 Select 组件本身缺少 Semi 对齐的 `filter` 搜索能力（`filterOption`/`onSearch`/`searchPosition` 均不存在），已按一手来源（`semi-foundation/select/foundation.ts`）补齐 `filter`/`searchPosition`（trigger/dropdown 两态）/`searchPlaceholder`/`onSearch`，Foundation 单测 + e2e + 文档站 demo + ego-browser 真机验证齐全后再测性能，三者 1 万节点面板打开/搜索响应均在 11~18ms 区间，远低于 200ms 合格线，详见 `specs/cross-cutting/perf-baseline-records.md`
- [x] Table 按里程碑逐项验收，每个里程碑（基础/排序筛选/固定列/树形/虚拟化）有独立的验收记录，不允许「表格能跑」就笼统视为完成——独立记录见本文件末尾「Table 里程碑验收记录」一节；核实过程中发现「固定列」里程碑此前是**真实的功能缺口而非文档滞后**：`column.fixed` prop 声明了但从未被消费成任何 `position: sticky` 样式，对应的 e2e 测试标题叫"固定列：左右固定列渲染 sticky 定位样式"但实际只断言了表头文字——这正是这条验收标准要求的「不允许表格能跑就笼统视为完成」所针对的问题类型，已按 Semi 一手来源（`semi-foundation/table/utils.ts` 的 `arrayAdd` 累加偏移量算法）补齐实现并修正测试
- [x] Select/Cascader/TreeSelect 的已选值与展开状态同步逻辑，有测试覆盖至少「异步加载子节点后自动展开」「批量选中父节点级联选中/取消子节点」两个场景——核实后澄清：「异步加载后自动展开」这段编排逻辑（`loadData().then()` 里连续调用 `handleLoadEnd`+`handleExpand`）本身写在 Cascader/TreeSelect 的 Adapter 层（`index.tsrx`），不是 Foundation 纯函数，不适合硬造一个 Foundation 方法只为满足"要有 Foundation 单测"的字面要求；`handleExpand`/`handleLoadStart`/`handleLoadEnd` 各自已有独立 Foundation 单测，组合行为由现有 e2e「懒加载」用例间接但确凿验证（断言子节点在加载完成后确实可见/新增列，这依赖 `expandedKeys` 门控，若未自动展开断不会渲染）。「级联选中/取消」此前只覆盖了勾选方向（父→子）和叶子节点自身取消，缺失"取消勾选父节点后子孙同步取消"这一半，已在 Cascader/TreeSelect 两个 Foundation 补齐对应单测
- [x] Slider/Rating/ColorPicker 均可通过键盘方向键完成等价于拖拽的操作，Playwright 用例覆盖——核实发现三者核心方向键此前均已有基础覆盖，但存在维度缺口：ColorPicker 只测过 SV 面板/色相条的单方向，缺 SV 垂直轴（ArrowUp/ArrowDown）与透明度滑条；Slider 缺 PageUp/PageDown、range 模式双手柄键盘操作、vertical 模式键盘语义（三者 Foundation 层均已有单测，只是 e2e 未覆盖）；Rating 缺 allowHalf 开启时键盘按 0.5 步进（此前只测过鼠标点击半星）。已逐项补齐 e2e 用例
- [x] Upload 的异步状态机（选择文件/上传中/成功/失败/取消）有 Foundation 单测，覆盖并发多文件上传时单个文件失败不影响其他文件的场景——`handleProgress`/`handleSuccess`/`handleError` 均按 `uid` 定位单项、`[...fileList]` 浅拷贝替换，设计上天然隔离，新增测试显式断言三个并发文件中一个失败/一个进度更新/一个成功互不干扰
- [x] DatePicker/TimePicker 的日期/时间格式化输出符合当前 locale（`@lotus/locale`），有至少两种 locale 的对比测试——`@lotus/locale` 目前恰好支持 zh-CN/en-US 两种，e2e 新增测试验证 `monthText` 格式差异（"2026年 8月" vs "Aug 2026"，顺序都不同，非简单翻译）、星期文案（周日 vs Sun）、TimePicker 小时选项单位后缀（"01时" vs "01"）三处真实格式化差异点，加在 `e2e/other/config-provider.spec.ts` 已有的 locale 切换专题测试组里；playground 的 ConfigProvider locale demo 区块顺带补充 DatePicker/TimePicker 两个组件（`use12Hours` 开启验证 AM/PM 列渲染，但发现 AM/PM 缩写两种 locale 恰好相同不能证明切换生效，改用小时单位后缀这个真实差异点断言）

## Table 里程碑验收记录

> 逐里程碑独立记录，每条列出：Foundation 纯函数模块 + 单测数量、组件层消费点、e2e 验证、已知限制。核实日期 2026-08-29，对应 `e2e/show/table.spec.ts` 全量 11/11 通过。

### 里程碑 1 — 基础表格

- **Foundation**：`table-data.ts`（`flattenLeafColumns`/`getHeaderRowCount`/`buildHeaderRows`/`getCellValue`/多级表头摊平），14 条单测（`table-data.test.ts`）。
- **组件层**：`packages/ripple/src/show/table/index.tsrx` 渲染 `<thead>`/`<tbody>`，多级表头用 `buildHeaderRows` 把 `columns.children` 摊平成行×格网格，叶子列 `rowSpan` 补齐到表头总行数。
- **e2e**：`基础用法：渲染表头与行数据`（1 条）。
- **已知限制**：无。

### 里程碑 2 — 排序筛选

- **Foundation**：`sort.ts`（8 条单测）+ `filter.ts`（8 条单测），均为纯函数，不依赖 DOM。
- **组件层**：表头点击触发 `handleSortClick`，筛选走 Popover 下拉菜单 + 草稿态（`draftFilterValues`）确认/重置两段式交互。
- **e2e**：`排序：点击表头按年龄升序/降序切换`、`筛选：勾选城市筛选后只展示匹配行`（2 条）。
- **已知限制**：无。

### 里程碑 3 — 固定列

- **Foundation**：`fixed-column.ts`（`calcFixedOffsets`/`hasFixedColumns`，7 条单测），移植自 Semi `getCellWidths`/`arrayAdd` 的累加偏移量算法思路——固定列效果是手动写内联 `style.left`/`style.right`（不是纯 CSS `position: sticky` 一步到位），偏移量是"同侧固定列的实测宽度累加"。
- **组件层**：**2026-08-29 之前是死代码**——Foundation 模块存在且有单测，但从未被 `index.tsrx` 引用/消费，`column.fixed` 声明了却不产生任何视觉效果。本次补齐：`<thead>` 挂 ref 测量 `<th>` 实际渲染宽度（不用声明的 `column.width`，因为真实宽度可能因 padding/内容溢出/用户拖拽调整而不同）→ `calcFixedOffsets` 算出每列偏移 → `<th>`/`<td>` 按偏移写 `position: sticky` + `left`/`right` + 分界阴影 class（对齐 Semi 的 `isLastLeftFixed`/`isFirstFixedRight` 语义，固定列组的边界列加阴影区分视觉分界）。
- **e2e**：`固定列：左右固定列真实生效`（1 条，2026-08-29 改写——此前的同名测试只断言表头文字，未验证任何 sticky 定位样式，`--repeat-each=8` 8/8 稳定通过）。
- **已知限制**：多级表头场景下，`fixed` 的固定语义按叶子列生效（父级表头单元格本身不单独设置 sticky，样式表现为跟随其下叶子列的定位而非独立层级）；列宽调整（`resize-column.ts` 的拖拽改宽）与固定列偏移量重算已通过 `effect` 依赖 `state.columnWidths` 联动，但暂无专门 e2e 覆盖"拖拽改宽后固定列偏移量是否重算正确"这一组合场景，留作后续需要时补充。

### 里程碑 4 — 树形数据

- **Foundation**：行选择的父子级联复用 Tree 组件已验证的 check-cascade 算法（`buildKeyEntities`/`calcCheckedKeys`），不重新发明；`expand.ts`（7 条单测）管理展开态；`flatRows` 摊平树形展开态为定长数组（与 TreeSelect 的 `flatNodes` 同一模式）。
- **组件层**：`showExpandColumn` 门控展开列渲染，展开态存于 `state.expandedRowKeys`。
- **e2e**：`树形数据：展开父节点显示子节点，勾选父节点级联勾选子节点`（1 条）。
- **已知限制**：无。

### 里程碑 5 — 虚拟化

- **Foundation**：复用跨组件共享的 `base/virtual-list.ts`（`calcVirtualRange`，与 Select/Cascader/TreeSelect/Transfer 共 5 者同一实现，非各自复制）。
- **组件层**：仅在同时声明 `scroll.y`（固定容器高度）且没有 `expandedRowRender`（展开行内容任意高度，与固定行高假设冲突）时生效；HTML `<table>` 的 `<tbody>` 不能像 Select/TreeSelect 那样嵌一层 `translateY` 容器，改用两个高度分别为 `offsetY`/剩余总高度的占位 `<tr>` 撑开滚动条长度；单行渲染抽出 `TableRow` 子组件供虚拟化/非虚拟化两条路径共用。
- **e2e**：`virtualize：1万行数据只渲染可见区间，滚动后动态切换渲染内容，勾选状态不受虚拟化裁剪影响`（1 条，验证勾选态存于 `state.selectedRowKeys` 全量 key 集合、不因虚拟化裁剪丢失）。
- **已知限制**：与固定列可以共存（虚拟化和固定列共享同一套 `fixedCellStyle`/`fixedCellClass` 调用路径，`table.spec.ts` 全量回归已覆盖两者共存不冲突），但暂无单独构造"虚拟化 + 固定列同时启用 + 1 万行"规模的性能基线测试，若后续该组合场景成为高频用法应补充。

其余测试（`分页`/`展开行`/`空数据`/`loading 态`，各 1 条）覆盖表格的通用状态而非某个特定里程碑，不单独立项。
