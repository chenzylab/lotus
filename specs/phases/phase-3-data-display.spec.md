# Phase 3 — 数据展示

> 依赖：Phase 2 已完成（复用 Popconfirm 阶段抽取的浮层定位 Foundation）。
> 组件清单见 `specs/component-inventory.md` 「Phase 3」小节，是 6 个阶段中组件数量最多的一批（23 项）。

## 目标

交付内容展示类组件。这批组件多数是纯展示/低状态复杂度（Avatar/Badge/Card/Tag/Empty/Descriptions/Highlight），但包含三个高复杂度组件——**Dropdown/Popover/Tooltip（浮层三兄弟）**、**Modal/SideSheet（模态容器二兄弟）**、**Carousel/Calendar（独立复杂交互）**——需要重点投入。

## 范围

- **浮层三兄弟（Dropdown/Popover/Tooltip）**：共用 Phase 2 抽取的 `popupPosition.ts` Foundation，本阶段只需在此基础上做 Adapter 层封装 + 各自的触发方式差异（hover/click/focus）。三者应共享同一个 `packages/foundation/base/trigger.ts`（参考 Semi 源码里 `trigger` 作为独立内部模块的设计，见 `semi-porting` skill 的参考对象）。
- **模态容器二兄弟（Modal/SideSheet）**：需要处理焦点陷阱（focus trap，Tab 循环不能跳出模态）、滚动锁定（body scroll lock）、Esc 关闭、遮罩点击关闭。这是本阶段 a11y 要求最高的组件，Foundation 层的焦点陷阱逻辑要能被 Modal 和 SideSheet 复用。
- **Carousel**：涉及手势/自动播放定时器，Foundation 层需要抽象「播放状态机」（playing/paused/hover-paused），定时器清理是重点测试对象。
- **Calendar**：日期计算逻辑（月份天数、闰年、周起始日国际化）适合完全下沉到 Foundation，是少数**不需要任何 DOM 概念、可以 100% 纯函数化**的 Foundation 实现，优先复用（如可行）成熟的日期库而非手写日期算法，但需确认所选日期库无框架依赖。
- **Table 排除在外**：Table 移到 Phase 4，因为它和 Select/Tree 系列共用虚拟化能力，此阶段不要提前做，避免与 Phase 4 的虚拟化 Foundation 重复实现。

## 依赖 Skill

`component-authoring`、`foundation-authoring`、`a11y-audit`（焦点陷阱是本阶段重点，务必调用此 skill 的 checklist 而非自行发挥）、`i18n-locale`（Calendar 的周起始日、月份名称）、`testing`

## 验收标准

- [ ] 清单文件中 Phase 3 全部条目勾选，满足 DoD
- [ ] Dropdown/Popover/Tooltip 三者共享同一个浮层定位 Foundation，代码搜索确认无重复实现（`grep` 三个组件目录，定位逻辑只应该 import 而非复制）
- [ ] Modal/SideSheet 的焦点陷阱有 Playwright 用例：打开后连续按 Tab N 次（N = 内部可聚焦元素数 + 2），验证焦点在模态内循环、不跳到背景内容
- [ ] Modal/SideSheet 打开时 body 滚动被锁定，关闭后恢复，且多个模态嵌套打开/关闭时锁定状态计数正确（不会一个模态关闭就误解锁另一个还开着的）
- [ ] Carousel 自动播放定时器在组件卸载、hover 暂停、手动切换时正确清理/重置，Playwright 验证长时间停留在页面不产生多余定时器堆积
- [ ] Calendar 的月份/星期文案来自 `@lotus/locale`，周起始日（周日 vs 周一）可配置且符合对应 locale 默认值
- [ ] Table 确认未在本阶段被提前实现（作为反向检查项，防止范围蔓延）
