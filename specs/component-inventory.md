# 组件清单与阶段归属

> 口径来源（交叉核对三方，取交集去重后的准确清单）：
> 1. 官网总览页 https://semi.design/zh-CN/start/overview （官方声明"80+ components"，给出分类计数）
> 2. 本地文档目录 `~/i/semi-design/content/{basic,navigation,input,show,feedback,other,plus,ai}`（82 个文档目录）
> 3. 本地源码目录 `~/i/semi-design/packages/semi-ui`（85 个组件目录，含无独立文档页的 `iconButton`）
>
> **修正记录**：初版清单误数为 76 个且漏收 Chart（图表）、IconButton，AI 分类下的 AIButton/AIIcon/AITag/AIFloatButton 经源码核实（`packages/semi-ui` 无对应独立目录）**不是独立组件**，而是 Button/Icon/Tag/FloatButton 的 AI 主题视觉变体（`theme`/`type` prop 层面的差异），已并入对应基础组件，不单列 DoD 条目，但会在对应组件的 SPEC 验收标准里要求支持该变体。Chart（Semi DV）经核实是"字节内部 VChart 的主题配置层封装"，非自研图表组件，故仍列入「待裁定」而非排期。
>
> **最终口径：实际统计各 Phase 清单条目共 83 个纳入 DoD 排期的自研组件/条目**（Phase 1: 16、Phase 2: 15、Phase 3: 23、Phase 4: 14、Phase 5: 12、Phase 6: 3；含 IconButton、Locale 这类非纯视觉条目）+ 4 项并入基础组件的 AI 主题变体要求（AIButton/AIIcon/AITag/AIFloatButton，不单列 DoD）+ Chart 1 项待裁定（见文末）。此数字大于源码目录数（85）是因为 IconButton 单列，小于「85 源码目录 + 4 官网 AI 变体名目」是因为 AI 变体不重复计数、`trigger`/`resizeObserver` 等内部基础设施不计入面向用户的组件清单。Phase 2 原清单误列的 Feedback（Result 结果页）经核实是 Ant Design 组件、Semi Design 无对标，已从清单移除。
>
> 本文件是唯一进度看板：每个组件完成 DoD（见 AGENTS.md 第 3 节）后在此打勾，不要另建进度文档。

分类对照：Semi `basic`→Basic 基础、`navigation`→Navigation 导航、`input`→Data Entry 数据录入、`show`→Data Display 数据展示、`feedback`→Feedback 反馈、`other`→Other 全局配置、`plus`→Plus 富媒体/工具类、`ai`→AI 智能化组件。

## Phase 1 — 基础层 + 核心表单 (Basic + 高频 Input)

- [x] Button 按钮（含 AI 主题变体，对应官网 AIButton）
- [x] IconButton 图标按钮（源码 `semi-ui/iconButton`，无独立文档页，随 Button 一并交付；复用 ButtonFoundation，未做多色 icon fill 增强）
- [x] Icon 图标（含 AI 主题变体，对应官网 AIIcon；524 个正式+lab 图标已全部生成）
- [x] Typography 字体排印
- [x] Divider 分割线
- [x] Space 间距
- [x] Grid 栅格
- [x] Layout 布局
- [x] FloatButton 悬浮按钮（含 AI 主题变体，对应官网 AIFloatButton；badge 支持待 Badge 组件就绪后补齐）
- [x] Resizable 可调整大小（8 方向手柄，拖拽算法在 Foundation 自研；ResizeGroup 多面板联动留作二期）
- [x] Input 输入框
- [x] InputNumber 数字输入框
- [x] Checkbox 多选框
- [x] Radio 单选框
- [x] Switch 开关
- [x] Form 表单

## Phase 2 — 导航 + 反馈 (Navigation + Feedback)

- [x] Tabs 标签页
- [x] Breadcrumb 面包屑
- [x] Steps 步骤条（basic/fill 两种变体；nav 可点击导航式变体因与 Tabs 高度重叠本期不做）
- [x] Pagination 分页
- [x] Anchor 锚点
- [x] BackTop 回到顶部
- [x] Navigation 导航
- [x] Tree 树形控件（完整版：展开收起 + 单选/多选三态级联 + 搜索过滤 + loadData 懒加载，用户明确要求不满足于 Phase 2 基础版）
- [x] Banner 通栏
- [x] Notification 通知（6 个 position 分组渲染；结构对齐 ToastListFoundation，unshift 插入队列头部）
- [x] Toast 轻提示（stack 折叠视觉已实现；ToastFactory 多实例高阶能力简化为单例模块，已在验收标准里注明是主动简化）
- [x] Popconfirm 气泡确认框（组合复用 Popover，未重新实现浮层定位）
- [x] Progress 进度条
- [x] Skeleton 骨架屏
- [x] Spin 加载中

## Phase 3 — 数据展示 (Show)

- [x] Avatar 头像
- [x] Badge 徽标
- [x] Card 卡片
- [x] Tag 标签（含 AI 主题变体，对应官网 AITag）
- [x] Empty 空状态（新增 @lotus/illustrations 包，完整复刻 Semi 的 8 场景 x 亮/暗 2 配色 = 16 个插图）
- [x] Descriptions 描述列表
- [x] Collapse 折叠面板
- [x] Collapsible 可折叠容器（无头展开容器，非 Panel 语义，独立于 Collapse）
- [x] Dropdown 下拉菜单
- [x] Popover 气泡卡片
- [x] Tooltip 文字提示
- [x] List 列表
- [x] Timeline 时间轴
- [x] Image 图片（含 ImagePreviewGroup 多图批量预览：缩放/旋转/拖拽平移/左右切换）
- [x] Carousel 走马灯（数据以 items 数组传入，非 Semi 原始的纯 JSX children——Ripple 无 React.Children.map 的必要调整）
- [x] Modal 对话框（暂不含 Modal.info/success/error/warning/confirm/destroyAll 静态便捷方法，后续单独评估命令式挂载 API）
- [x] SideSheet 侧边栏（placement 四方向、size 预设、keepDOM，无 Semi 等价的静态便捷方法）
- [x] Calendar 日历（仅 week/month 模式，不含 range/day 模式；重叠事件分组算法对齐 Semi 简化版——仅同起止时间并排，非通用区间重叠检测）
- [x] OverflowList 自适应列表（仅 renderMode=collapse，不含 scroll 模式；ResizeObserver 驱动的两阶段渲染+线性累加折叠算法）
- [x] ScrollList 滚动列表（wheel/normal 两种模式 + cycled 循环滚动，交互完全依赖原生滚动+JS吸附判定，对齐 Semi 的"零自研拖拽层"设计）
- [x] Highlight 高亮（三段式纯函数流水线算法：findChunks→combineChunks→fillInChunks，对齐 Semi 的重叠合并策略）
- [x] Cropper 图片裁剪（自研坐标系：`centerPoint` 表达图片/裁切框位置，8 方向拖拽+可选 aspectRatio 锁定，滚轮以鼠标为锚点缩放，绕裁切框中心旋转；导出用 Canvas 2D `getImageData`/`putImageData` 处理越界裁切；主动新增 Semi 没有的 `onCrop` 声明式回调 + `getCropperApi` 命令式 API 并存）
- [x] UserGuide 用户引导（popup/modal 两种模式；popup 用 SVG `<mask>` 镂空遮罩 + 复用 Tooltip/Popover 的共享定位引擎（虚拟锚点=高亮框矩形，不重复实现坐标数学）；主动修正 Semi 源码的 `||` 吞掉 `spotlightPadding: 0`、状态机负索引边界 bug；新增键盘方向键/ESC、resize 自动重定位——Semi 完全空白；不做 Semi 半成品的 `getPopupContainer`）

## Phase 4 — 复杂数据录入与展示 (Data Entry 高阶 + Table)

> 这批组件大多存在非平凡状态机和/或大数据虚拟化需求，Foundation 层价值最高，同时是 `perf-baseline` skill 的主要适用对象。

- [x] Select 选择器（提前于 Phase 1 随核心表单一并交付）
- [x] Cascader 级联选择（单个 Popover + 内部横向 flex 多列面板，对齐 Semi 架构不做多浮层依次定位；多选三态级联直接复用 Tree 的 check-cascade 算法，Semi 源码本身也是同一份算法；`autoMergeValue`/`leafOnly`/`checkRelation` 选中态折叠层为 Cascader 特有；搜索用路径打平匹配，模型与 Tree 的"展开祖先链"不同；支持 loadData 异步懒加载）
- [x] TreeSelect 树形选择（"Select 式触发器外壳 + Tree 渲染逻辑内联进浮层"，算法层 100% 复用 Tree 的 tree-data/check-cascade/expand/search 四个纯函数模块零改动，不重新实现；不直接嵌入整个 Tree 组件避免双重搜索框/状态同步问题；新增 `checkRelation='unRelated'` 独立勾选分支与 `maxTagCount` 多选标签折叠——lotus 目前唯一支持标签折叠的选择器类组件）
- [x] AutoComplete 自动补全（增强型 Input 而非选择器：允许自由文本，无内置候选项过滤/匹配算法，`data` 展示什么完全由消费方在 `onSearch` 回调里自行决定；复用 Cascader 已验证的 Popover(trigger="custom") + document mousedown 双 contains 判断浮层开关模式，但触发器点击语义改为"仅关闭态点击才打开，已打开时点击输入框内部不关闭"——因为触发器本身是可编辑文本框，不能像 Cascader/TreeSelect 那样无条件 toggle；键盘导航含循环回绕、跳过 disabled 项）
- [x] DatePicker 日期选择器（参考同源项目 chenzy.design 的 Semi 对齐实现移植，date-fns 驱动，是 lotus Foundation 层第一次引入外部依赖；覆盖全部 7 种 type：date/dateRange/dateTime/dateTimeRange/month/monthRange/year；date/dateRange 走日历网格，month/monthRange/year 走独立的 ScrollList/ScrollItem 年月滚轮，dateTime 系列复用 TimePicker 拆出的 TimeColumns 时间列；range 选择状态机、双面板防撞月导航、disabledDate、presets 快捷选项、needConfirm+Footer 确认流程、点导航标题 drill-down 到年月滚轮再跳回日历网格均已实现；insetInput 面板内输入框未接入 UI 层（Foundation 方法已就绪，留作后续迭代）；timeZone 时区转换未实现（Semi 该特性依赖 date-fns-tz + IANA 偏移表，收益/成本比低，明确排除在外））
- [x] TimePicker 时间选择器（为支撑 DatePicker 的 dateTime 系列而先行拆出：触发器复用 Input 可键入时间串，面板复用 ScrollList/ScrollItem 滚动列；type='time' 单选/type='timeRange' 范围选择共用同一个可编辑输入框，按 rangeSeparator 拆两端；12 小时制 AM/PM 列、disabledHours/Minutes/Seconds、hideDisabledOptions、按已选值联动的 disabledTime 全部对齐 Semi；浮层开关复用 AutoComplete 已验证的"仅关闭态点击才打开"模式）
- [x] Slider 滑动输入条（单值/range 双滑块共用同一组件，`range` prop 切换，对齐 Semi 的设计；拖拽状态机移植自 Semi semi-foundation/slider/foundation.ts 的像素↔数值换算算法，range 模式两手柄允许贴住不允许穿越——越界时两值一起收缩到静止那一端的当前值；键盘方向键/PageUp/PageDown/Home/End 完整实现，range 下 Home/End 对贴住对侧手柄而非跳全局边界；marks 刻度标记、tipFormatter 自定义提示、vertical 垂直方向、disabled 均已实现；rail 点击跳转按像素距离判定操作哪个手柄）
- [x] Rating 评分（像素↔分值换算、hover 预览、点击清零、键盘环绕移植自 Semi semi-foundation/rating/foundation.ts 算法；`allowHalf` 半星判定按点击/悬停位置在星星宽度内的比例 <0.5 算半星；`allowClear` 控制再次点击已选值是否清零，清零后有 `clearedValue` 守卫防止 hover 视觉复原；键盘方向键越界是环绕（wrap-around）不是钳制——超过 count 直接归零、低于 0 直接跳到 count；星星填充用"背景星+裁剪叠层星"两层 CSS 实现半星视觉，比 Semi 原始双 role=radio 结构简化，整组只用一个可聚焦容器+方向键操作，未做逐星 roving tabindex）
- [x] ColorPicker 颜色选择器（参考 Semi semi-foundation/colorPicker 算法思路 + 同源项目 chenzy.design 已验证实现；内部统一用 `{hsva,rgba,hex}` 三态 ColorValue，hsva 刻度对齐 Semi 原生 h:0-360/s,v:0-100/a:0-1，不引入 0-1 归一化刻度；三个可拖拽区域（饱和度-明度矩形/色相条/透明度条）统一走 document 级 mousemove/mouseup，复用 Slider 已验证的拖拽模式；Semi 源码没有 presetColors/disabled/onChangeComplete、也完全没有键盘交互，不额外发明前两者，但补上方向键步进的键盘无障碍能力对齐 chenzy.design 的增强方案；usePopover 模式下 children 缺省时渲染默认色块触发器；eyeDropper 基于 window.EyeDropper 特性检测，不支持时自动隐藏按钮）
- [x] Transfer 穿梭框（三方独立调研交叉验证：Semi 源码 + chenzy.design 复用评估 + lotus 基础设施现状，核心发现是单一数据源 + selectedItems Map 的"勾选即迁移"模型，不是经典双栏移动箭头模型；对 Semi 主动修正 3 处：value 缺省 fallback 到 key、搜索过滤不区分 treeList 统一走同一条 Foundation 路径、拖拽排序遵循受控检查；draggable 拖拽排序与 virtualize 虚拟化互斥，均已实现，新增两个跨组件可复用的基础算法模块 `base/sortable-drag.ts`（pointer 位移→目标索引换算）和 `base/virtual-list.ts`（固定行高虚拟滚动区间计算），供后续可排序 List/Table 等组件复用；type='list'/'groupList'/'treeList' 三种数据形态全部支持，treeList 左侧复用内部 `<Tree multiple>` 组件的三态级联算法；键盘无障碍能力 Semi 和 chenzy.design 两方均薄弱，本次未做超出 Checkbox 原生 Tab/Space 之外的额外增强，是明确的已知短板，留作后续迭代）
- [x] Upload 上传（Semi 源码 + chenzy.design 双重调研核实；XHR 构造/FormData 拼装/onprogress 监听完全下沉到 Ripple 组件层，Foundation 只提供 markUploading/handleProgress/handleSuccess/handleError 等纯状态迁移方法，对齐 lotus 既有的 TreeSelect loadData 惯例，优于 Semi 把 XHR 直接塞进 Foundation 类方法的做法；listType 只做三档 list/picture/none，不做 Semi 不存在的 picture-list；不实现并发队列/pause/abort——chenzy.design spec 文档声称有但实际代码未落地，是文档超前于代码的陷阱；键盘无障碍对齐 chenzy.design 已验证的增强方案（role="button"+tabIndex+onKeyDown Enter/Space），不对齐 Semi 原始的键盘空白状态；对 Semi 主动修正：checkFileSize 显式 undefined 守卫、timeout 若支持须真正接到 xhr.timeout；draggable 拖拽区域 + picture 图片墙缩略图 + maxSize/limit 校验均已实现）
- [x] TagInput 标签输入框（Semi 源码 + chenzy.design 双重调研核实；纯自由文本输入，无候选下拉，非 AutoComplete；标签渲染直接复用 Tag 组件（color="white" type="light"，真实 button 关闭按钮天然键盘可达）；maxTagCount 折叠复用 TreeSelect 已验证的 foldTags 纯函数，展开状态用独立 restExpanded 布尔量而非 Semi 隐式耦合在容器 active 全局态的设计；draggable 拖拽排序新增 flex-wrap 二维几何算法（computeTargetIndexWrap/computeItemTransformsWrap，移植自 chenzy.design 已验证的纯函数，补齐 lotus base/sortable-drag.ts 此前只有 1D 单轴版本的缺口）；"+N" 折叠气泡主动补充 role="button"+tabIndex+onKeyDown 键盘可达性——Semi 和 chenzy.design 两方在这一点均是空白，对齐 Upload 组件已验证过的增强模式）
- [x] PinCode 验证码输入框（Semi 源码 + chenzy.design 双重调研核实；每格手写裸 input（lotus Input 组件不支持 DOM ref 暴露，对齐 Upload/TagInput 已验证结论）；忠实对齐 Semi 的行为怪癖（Backspace 无条件清空当前格不判断是否已空、onComplete 判定写入索引是否为末格而非全部非空）；format 只支持 number/mixed/RegExp/function 四种，不引入 Semi 测试文件里出现但源码类型不支持的 'text' 幽灵值，也不做 Semi 完全没有的 'mask' 遮罩显示；键盘无障碍（role="group"+位次 aria-label+autocomplete="one-time-code"+IME 组合输入精确处理）完整对齐 chenzy.design 方案——这是少见的"Semi 全面空白、chenzy.design 全面补齐"的组件）
- [x] Table 表格（含虚拟化/树形数据）（Semi 源码 + chenzy.design 双重调研核实；用户明确选择三期能力一次性交付，不做分期后置；数据管线（排序 → 筛选 → 分页 → 打平）与行选择/展开/树形三态级联全部下沉 Foundation 纯函数模块（table-data/sort/filter/row-selection/expand/fixed-column/resize-column），组件层只做 DOM 渲染与事件转发；行选择的父子级联复用 Tree 组件已验证的 check-cascade 算法（buildKeyEntities/calcCheckedKeys），不重新发明；多级表头用 buildHeaderRows 把 columns.children 摊平成行×格网格，叶子列 rowSpan 补齐到表头总行数；方向键单元格导航明确不做——Semi 和 chenzy.design 两方均验证过判定不需要，维持原生 Tab 序；aria-label 挂在最外层 wrapper 而非 `<table>` 本身，便于测试和外部脚本定位整个 Table 区域）

## Phase 5 — 全局配置 + 富媒体/工具类 (Other + Plus)

- [x] ConfigProvider 全局配置（此前已随各输入类组件的 locale 需求顺带实现，本次核实补勾：纯 Context Provider，`LocaleContext.set()` 响应式下发 `LocaleShape`，切换 locale 后子树文案实时更新不需要重新挂载；无独立 Foundation——组件本身无状态机，只做透传，符合"纯展示/透传型组件可以没有 Foundation"的惯例；已有专门 e2e 覆盖 `e2e/other/config-provider.spec.ts`，3 个用例全过）
- [x] Locale 国际化（对接 `@lotus/locale`，非独立视觉组件；同上一并核实完成，覆盖 Form/Input/InputNumber/TextArea/Select/Modal/Calendar/UserGuide/TimePicker/DatePicker 共 10 个组件的 zh-CN/en-US 双语词条，`LocaleShape` 类型定义于 `packages/locale/src/types.ts`）
- [ ] Sidebar 侧边栏容器（Plus/AI 分类，纳入此阶段做通用容器）
- [x] CodeHighlight 代码高亮（对齐 Semi semi-ui/codeHighlight：底层 prismjs，Foundation 层为纯函数 `resolveCodeClassName`，无状态机；DOM 结构 div > pre > code，`textContent` 纯文本写入 + `Prism.highlightElement` 就地高亮，不经 innerHTML，规避 XSS；props 严格对齐 Semi 真实 API（code/language/lineNumber/defaultTheme/class/style），不臆造 copyable 等 Semi 没有的丰富特性；e2e 覆盖 `e2e/show/code-highlight.spec.ts`，6 用例 30/30（`--repeat-each=5`）全过）
- [x] MarkdownRender Markdown 渲染（Semi 用 `@mdx-js/mdx` evaluate 编译成 React 组件，lotus 无 jsx-runtime 无法复用，改用 unified/remark-parse/remark-gfm/remark-rehype 管线把 markdown 编译到 hast（HTML AST），渲染层用 tsrx 动态标签语法 `<{node.tagName}>` 递归渲染成真实 DOM；XSS 防护走架构级方案——全程不经过 HTML 字符串/innerHTML，`remark-rehype` 的 `allowDangerousHtml` 保持默认 false，markdown 源码内嵌的 raw HTML 在编译期被直接丢弃，不引入 DOMPurify；围栏代码块复用已有 CodeHighlight 组件（对齐 Semi markdownRender/components/code.tsx 的语言探测转发模式），行内代码渲染为 simple-code span；Foundation 层 `compileToHast`/`hastPropsToAttrs` 均为纯函数，无状态机；e2e 覆盖 `e2e/show/markdown-render.spec.ts`，8 用例 40/40（`--repeat-each=5`）全过，含 `<script>` 注入的显式回归测试）
- [x] JsonViewer JSON 查看器（Semi 对应实现是 Plus 付费组件，底层克隆 VS Code 文本编辑器内核 `@douyinfe/semi-json-viewer-core`（私有 npm 包，40+ 文件的 piece-tree 文本缓冲区），与 lotus 轻量自研风格不符，调研后确认不移植；lotus 走"结构化树查看器"定位而非"文本编辑器"定位——Foundation 层是真正的状态机（`JsonViewerFoundation`+`expandedPaths: Set<string>`，复用 Tree 组件同款"path 当 key + Set 管理展开集合"设计思路，但节点标识用从根拼接的路径字符串而非显式 KeyEntities 索引），纯函数部分负责 JSON 值→树结构转换（`buildJsonTree`/`parseToJsonTree`）与还原（`jsonTreeToValue`）；渲染层递归组件按值类型（object/array/string/number/boolean/null）分支渲染，数组元素不显示下标 key 前缀（对齐通行 JSON viewer 惯例）；复用已有 Typography 的 `CopyableAction` 组件做复制按钮，不重新实现；e2e 覆盖 `e2e/show/json-viewer.spec.ts`，7 用例 35/35（`--repeat-each=5`）全过）
- [x] Chat 聊天组件（基础版，AI 交互增强见 Phase 6；调研确认 Semi 本身对"流式响应"也只是浅层回调钩子，没有真实 SSE/增量渲染基础设施，基础版与 Semi Chat 实质对等，不是从 Semi Chat 阉割字段而是本来就是独立组件；Message 结构裁剪为 role/id/content/status(loading|complete|error)/like/dislike，content 本阶段只做纯文本；Foundation 层是状态机（`ChatFoundation`+`chats`/`inputValue`，chats 权威状态优先受控，对齐 Transfer 组件"方法接收 isControlled 参数、Foundation 不持有 props"的既有模式），复杂变换下沉到纯函数模块 `chat-message.ts`；渲染层复用已有 Avatar 做头像、TextArea 做输入框主体（含 `onEnterPress` 组合输入处理）；不做真实 AI 生成语义的 `showStopGenerate`/`onMessageReset`/附件上传/markdown 渲染，避免范围蔓延到 Phase 6；e2e 覆盖 `e2e/show/chat.spec.ts`，9 用例 45/45（`--repeat-each=5`）全过）
- [x] AudioPlayer 音频播放器（Semi 对应实现属于 Plus 分类，Foundation 层与 Carousel 的自动轮播定时器状态机重合度低——AudioPlayer 的"时钟"是浏览器原生 `<audio>` 元素派发的 timeupdate/ended/error 事件而非自驱动的 setInterval，两者只在"多曲/多帧取模循环索引"这个两行惯用法上思路一致，不共享基类；Foundation 只做纯状态迁移计算，不直接操作 DOM，真实的 play()/pause()/设置 currentTime 等由 `.tsrx` 渲染层在调用完 Foundation 方法后自行触发；不复用通用 Slider，自建 AudioSlider 子组件做进度条/音量条（对齐 Semi 自建 audioSlider.tsx 的既有设计）；e2e 覆盖 `e2e/show/audio-player.spec.ts`，9 用例 150/150（`--repeat-each=15`）全过，含测试环境下 audio 元素 currentTime 赋值需整体打桩的踩坑记录）
- [x] VideoPlayer 视频播放器（Semi 对应实现属于 Plus 分类；调研确认与 AudioPlayer 实际复用度低——只有 `clampVolume`/`clampTime` 两个数值钳制纯函数可直接 import 复用，`formatTime`/倍速档位/多曲目类型均需独立实现（视频时长常见超一小时需要 H:MM:SS 分支，倍速是 5 档降序含 1.25x 而非 AudioPlayer 的 5 档升序，且 VideoPlayer 无多曲目播放列表概念）；Foundation 层延续"只做纯状态计算、不碰 DOM"原则，全屏/画中画的真实浏览器 API 调用（`requestFullscreen`/`requestPictureInPicture`）与四前缀兼容判断都放在 `.tsrx` 渲染层，Foundation 只翻转意图或从 `fullscreenchange`/`leavepictureinpicture` 事件回写真实状态；进度条/音量条直接跨组件复用 AudioPlayer 已有的 `AudioSlider` 子组件（水平/垂直滑块的几何计算与媒体类型无关）；e2e 覆盖 `e2e/show/video-player.spec.ts`，9 用例 45/45（`--repeat-each=5`）全过，复用 AudioPlayer 排查出的"测试环境 currentTime 整体打桩"经验一次性避免重复踩坑）
- [x] Lottie 动画（对齐 Semi semi-ui/lottie：真实存在的正式组件（非 Plus 草稿），本质是 lottie-web（`^5.13.0`）的极薄容器——Semi 源码 `LottieBaseState` 是空接口，没有内部状态机，也没有 autoplay/loop/speed/direction 等独立顶层 props，全部通过必填的 `params` 透传给 `lottie.loadAnimation`（默认 `renderer:'svg', loop:true, autoplay:true`，用户 params 逐项覆盖）；命令式播放控制（play/pause/stop/setSpeed 等）不由 lotus 自己封装，通过 `getAnimationInstance` 回调交出原生 `AnimationItem` 实例解决（对齐 Cropper 组件 `getCropperApi` 的"回调交出真实操作句柄"既有模式）；Foundation 层只有一个纯函数 `resolveLoadParams`，无状态机，与 CodeHighlight 同一惯例；e2e 覆盖 `e2e/show/lottie.spec.ts`，4 用例 20/20（`--repeat-each=5`）全过）
- [x] DragMove 拖拽移动（对齐 Semi semi-ui/dragMove：Plus 分类组件，是 Modal draggable 能力的底层实现；支持 absolute/relative 两种定位策略、`constrainer`（'parent' 或自定义函数）约束容器、`handler` 拖拽把手、`allowMove`/`customMove`/`allowInputDrag`、鼠标+触摸双套事件；Foundation 层是三段式生命周期状态机（onDragStart 缓存起点快照→onDragMove 纯计算→onDragEnd 清理），对齐 ResizableFoundation 同构模式；lotus 现有 sortable-drag.ts 排序算法复用度为 0（问题域不同，只有拖拽生命周期模式可参照），Cropper 拖拽实现的 clamp 边界钳制算法可直接参照；e2e 覆盖 `e2e/basic/drag-move.spec.ts`，5 用例 50/50（`--repeat-each=10`）全过。真机验证阶段发现并修复一个真实的坐标系混淆 bug：`onDragStart` 起始偏移量最初误用 `getBoundingClientRect()`（视口坐标）而非 `element.offsetLeft`（与 `style.left` 同一坐标系），导致连续拖拽的第一段位移量系统性偏差，对照 Semi 源码 `_calcOffset` 逐行核对定位到根因并修复）
- [x] HotKeys 快捷键（对齐 Semi semi-ui/hotKeys：Plus 分类组件，数组语法（`['control','s']`，非 `'ctrl+s'` 字符串）；匹配算法（修饰键精确布尔比较+普通键 code 优先/key 回退）以纯函数移植自 chenzy.design 已验证实现，无状态（不维护"当前按下按键集合"，每次 keydown 独立判断），不需要 Foundation<S> 状态机，与 CodeHighlight/Lottie 同一惯例；`mergeMetaCtrl` 是 Semi 自己的死 prop（声明但从未参与匹配逻辑），本次严格对齐不做修正也不做跨平台 mod 别名扩展；默认渲染键位提示 UI（div+span 徽章+`+`分隔符），`render` 传 null 时不渲染任何节点；e2e 覆盖 `e2e/basic/hotkeys.spec.ts`，6 用例 30/30（`--repeat-each=5`）全过）

## Phase 6 — AI 智能化组件 (AI)

> 依赖 `specs/references/semi-design-articles.md` 中「AI」一节的五大设计原则与四阶段交互模型。此阶段组件需要 Token 层先行提供 AI 专属渐变色变量。

- [ ] AiChatDialogue AI 对话
- [ ] AiChatInput AI 输入框
- [ ] AiComponent AI 组件（过程感知/结果控制类通用组件）

## 图标资产移植（随 Phase 1 启动，独立于组件 DoD 流程）

- **来源**：`~/i/semi-design/packages/semi-icons`（523 个正式图标，MIT License）+ `~/i/semi-design/packages/semi-icons-lab`（84 个实验性图标）。
- **移植方式**：SVG 源文件（`src/svgs/*.svg`）是纯图形资产，不含框架代码，符合 `semi-porting` skill「可直接搬运」类别。生成流程（`svgo` 清洗 SVG → 模板生成组件）思路可参考 Semi 的 `scripts/build-svg.js`，但生成目标模板改为 lotus 自己的 tsrx 组件模板（Semi 生成 React `.tsx`，lotus 需生成 `.tsrx`），脚本本身用 lotus 风格重写，不直接跑 Semi 的 build 脚本。
- **产出**：`packages/icons` 下 523+84 个图标各自导出一个 tsrx 组件，支持按需引入（单独 import 不拖累其他图标打包体积，验收标准见 Phase 1 SPEC）。
- **验收**：图标视觉（`viewBox`/path 数据）与 Semi 原图标一致（可直接复用图形数据），组件命名/API 用 lotus 规范（如 `<IconPulse />` 而非套壳保留 `convertIcon` 这类 Semi 内部实现细节）。
- 详细执行清单见 `specs/phases/phase-1-basic-form.spec.md` 的 Icon 相关验收项，以及 `.claude/skills/semi-porting/SKILL.md`。

## 待裁定 / 观察项

- **Chart 图表（官网称 "Semi DV"）**：核实 `~/i/semi-design/content/show/chart/index.md` 后确认——这不是自研图表组件，而是"基于字节内部开源可视化引擎 VChart（`@visactor/vchart`）的主题配置层封装"，本体逻辑在 VChart，Semi 只做主题 Token 适配。lotus 若要做同等能力，前提是先选定一个开源图表库（VChart 本身开源可用），再做 lotus Token → 图表主题的映射层，工作性质和"组件实现"完全不同。暂不排入 Phase，待明确图表需求后单独开 `specs/cross-cutting/chart-theming.spec.md`。
- **Icon 图标资产**：不是单一组件，而是 `packages/icons` 整包工程（SVG 源 + 生成的 tsrx 组件），随 Phase 1 启动但独立于组件 DoD 流程，规范见 `specs/cross-cutting/icons.spec.md`（如需要再补）。
- **AI 主题变体的具体视觉规范**（渐变色、边框、hover 态）依赖 `specs/cross-cutting/theme-tokens.spec.md` 中 AI 专属变量先行落地，Phase 1/3 涉及 AI 变体的组件验收时一并检查，不等到 Phase 6 才补。
