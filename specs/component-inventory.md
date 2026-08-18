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
- [ ] Card 卡片
- [x] Tag 标签（含 AI 主题变体，对应官网 AITag）
- [ ] Empty 空状态
- [ ] Descriptions 描述列表
- [ ] Collapse 折叠面板
- [ ] Collapsible 可折叠容器
- [x] Dropdown 下拉菜单
- [x] Popover 气泡卡片
- [x] Tooltip 文字提示
- [ ] List 列表
- [ ] Timeline 时间轴
- [ ] Image 图片
- [ ] Carousel 走马灯
- [ ] Modal 对话框
- [ ] SideSheet 侧边栏
- [ ] Calendar 日历
- [ ] OverflowList 自适应列表
- [ ] ScrollList 滚动列表
- [ ] Highlight 高亮
- [ ] Cropper 图片裁剪
- [ ] UserGuide 用户引导

## Phase 4 — 复杂数据录入与展示 (Data Entry 高阶 + Table)

> 这批组件大多存在非平凡状态机和/或大数据虚拟化需求，Foundation 层价值最高，同时是 `perf-baseline` skill 的主要适用对象。

- [x] Select 选择器（提前于 Phase 1 随核心表单一并交付）
- [ ] Cascader 级联选择
- [ ] TreeSelect 树形选择
- [ ] AutoComplete 自动补全
- [ ] DatePicker 日期选择器
- [ ] TimePicker 时间选择器
- [ ] Slider 滑动输入条
- [ ] Rating 评分
- [ ] ColorPicker 颜色选择器
- [ ] Transfer 穿梭框
- [ ] Upload 上传
- [ ] TagInput 标签输入框
- [ ] PinCode 验证码输入框
- [ ] Table 表格（含虚拟化/树形数据）

## Phase 5 — 全局配置 + 富媒体/工具类 (Other + Plus)

- [ ] ConfigProvider 全局配置
- [ ] Locale 国际化（对接 `@lotus/locale`，非独立视觉组件）
- [ ] Sidebar 侧边栏容器（Plus/AI 分类，纳入此阶段做通用容器）
- [ ] CodeHighlight 代码高亮
- [ ] MarkdownRender Markdown 渲染
- [ ] JsonViewer JSON 查看器
- [ ] Chat 聊天组件（基础版，AI 交互增强见 Phase 6）
- [ ] AudioPlayer 音频播放器
- [ ] VideoPlayer 视频播放器
- [ ] Lottie 动画
- [ ] DragMove 拖拽移动
- [ ] HotKeys 快捷键

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
