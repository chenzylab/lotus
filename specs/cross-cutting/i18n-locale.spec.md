# 横切能力 SPEC — 国际化 (i18n)

> 设计依据：`specs/references/semi-design-articles.md` 「i18n」一节。

## 目标

`@lotus/locale` 提供文案 Token 化能力，使组件面向用户的文案（错误提示、占位符、月份/星期名称、"确定/取消"按钮文案等）100% 可替换，并原生支持 RTL 布局。

## 范围

- **Locale 数据结构**：每种语言一个文案包（如 `zh-CN.ts`/`en-US.ts`），按组件命名空间组织（如 `locale.Form.required`、`locale.DatePicker.today`），而非扁平 key，避免大型语言包难以维护。
- **首批语言**：中文简体、英文必须优先交付（覆盖开发过程中的自我验证）；日文、韩文、阿拉伯文（RTL 代表）作为第二批，用于验证文案长度差异与 RTL 布局是否真正生效，不能只支持中英文就宣称国际化完成。
- **RTL 支持**：Token 层使用逻辑属性（`margin-inline-start` 而非 `margin-left`、`inset-inline-end` 而非 `right`），而不是为 RTL 单独写一套镜像样式补丁。方向性图标（如箭头）在 RTL 下需要有翻转变体，此规则在 `component-authoring` skill 的 checklist 中列出，每个涉及方向性图标的组件都要检查。
- **格式化能力**：日期/数字/货币格式化不硬编码到组件里，通过 `@lotus/locale` 暴露格式化函数，具体实现可以包装成熟的国际化格式化库（不要求自研 ICU 消息格式解析器）。

## 验收标准

- [x] 任意面向用户的文案字符串搜索（`grep` 中文/英文硬编码字符串于 `packages/ripple/src` 下）应为零命中（测试/注释除外）——`grep '"[一-龥]'` 排除注释/import 后，找到唯一真实命中：`DatePicker` 左右两个月历面板的 `Navigation` 组件调用点硬编码了 `prevYearLabel="上一年"`/`prevMonthLabel="上个月"`/`nextMonthLabel="下个月"`/`nextYearLabel="下一年"` 四个 `aria-label`（`monthText` 本身已正确走 `locale.DatePicker.monthText`，只有这四个遗漏）。已在 `DatePickerLocale` 类型和 zh-CN/en-US 语言包补上对应字段，组件改为消费 `locale.DatePicker.xxxLabel`；核实中顺带发现右侧面板（双月 range 模式）的 `Navigation` 完全没有传 `rtlIconStyle`，是此前 RTL 镜像工作遗漏的一处，已一并补上。新增 e2e 验证这四个 aria-label 跟随 locale 切换
- [x] Form 组件切换 locale 后，校验错误文案实时更新（不需要重新挂载组件）——`e2e/other/config-provider.spec.ts` 已有对应测试，纯文档滞后未勾选
- [ ] DatePicker/Calendar 的月份名称、周起始日在切换到日语/阿拉伯语 locale 后正确显示，且阿拉伯语场景下整体布局镜像（非文案本身镜像，是布局方向）——核实 `@lotus/locale` 目前只有 zh-CN/en-US 两个语言包，spec 范围里明确规划的"第二批"语言（日文、韩文、阿拉伯文）尚未交付，这是真实缺口而非文档滞后。经用户确认本次不展开翻译工作，留待后续专门安排
- [x] RTL 模式下方向性图标视觉上正确翻转——**这条验收标准列举的两个例子本身有误，如实修正**：核对源码确认 Breadcrumb 默认分隔符是文本 `/`（Semi 一手来源同样如此），不是箭头图标；Collapse 用 `IconChevronUp/Down` 垂直箭头，垂直方向不受 RTL 影响，两者都不需要处理。真正需要镜像的是水平方向、带阅读顺序语义的图标，核实后发现 6 个组件确实完全没做：Pagination 上/下页、DatePicker 上/下月+上/下年、Carousel 左右切换箭头（含位置镜像）、Image 预览上一张/下一张、AudioPlayer 上一曲/下一曲、Sidebar 返回箭头，均已用 `locale.dir === 'rtl' ? { transform: 'scaleX(-1)' } : undefined` 补齐（对齐 Semi 一手来源 `rtl.scss` 的 `scaleX(-1)` 方案），Carousel/Image 预览的箭头容器物理位置同步改用 `inset-inline-start/end` 逻辑属性镜像。核实中顺带发现并修复一处与 RTL 无关的既有缺陷：AudioPlayer 快退/快进按钮此前用 `«`/`»` 文本符号占位，`@lotus/icons` 早已移植好 `IconBackward`/`IconFastForward` 却未使用，已换成真正图标（核对 Semi 一手来源确认这两个图标本身不受 RTL 镜像，是媒体控制通用符号约定）。ego-browser 真机验证全部 6 处镜像 + e2e 固化，`--repeat-each=5` 稳定通过
- [x] 新增语言包时不需要修改任何组件代码（纯数据层扩展），作为架构正确性的反向验证——核实发现 `Calendar` 组件的 `formatHour` 函数内部硬编码 `if (locale === 'zh-CN')` 分支判断 24 小时制/12 小时 AM-PM 制，是真实违反本条要求的架构缺陷（新增日语等 24 小时制语言会命中错误分支）。核对 spec 范围"格式化能力通过 `@lotus/locale` 暴露格式化函数"的要求，已将格式化逻辑下沉为 `CalendarLocale.formatHour(hour)` 函数，zh-CN/en-US 各自实现，组件删除硬编码分支改为调用 `locale.Calendar.formatHour(hour)`；新增 e2e 验证跟随 locale 切换（过程中发现新增的 Calendar demo 因未传 `height` prop 撑破外层容器、拦截了后续测试按钮的点击，属于 demo 用法问题不是组件缺陷，已修正）
