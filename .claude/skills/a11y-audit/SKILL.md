---
name: a11y-audit
description: 每个组件完成前的无障碍自检必经步骤。对照 WCAG 2.0 + ARIA 检查色彩对比度、键盘导航、语义化、焦点管理、动画安全性。对照 specs/cross-cutting/a11y.spec.md 执行，无组件可豁免。
---

# a11y-audit

## 何时使用

**每个组件在标记为完成前必须过一遍此检查**，无例外（对照 `specs/cross-cutting/a11y.spec.md`「适用范围」——这是唯一没有豁免条款的横切能力）。

## 检查清单（逐项过，不要跳步）

### 1. 色彩对比度
- [ ] 查该组件使用的所有文本颜色变量，常规文本与背景对比度 ≥ 4.5:1，大文本（≥18px）≥ 3:1
- [ ] hover/active/focus 状态色与相邻背景对比度 ≥ 3:1
- [ ] 若组件用颜色传达状态（如成功/失败），确认同时有图标或文本冗余提示，不是仅靠颜色区分
- 具体数值计算/校验方法参照 `theme-tokens` skill

### 2. 键盘操作
- [ ] 用 Tab 键能到达组件所有可交互元素，顺序符合视觉/逻辑顺序
- [ ] 组内导航（多选项类组件如 Radio 组/Menu/Tabs）支持方向键
- [ ] Enter/Space 能触发主要操作
- [ ] 若组件是浮层/模态，Esc 能关闭
- [ ] 初始焦点位置合理：破坏性操作焦点在安全选项，常规流程焦点在推荐操作
- [ ] 浮层/模态关闭后焦点归还到触发元素（写 Playwright 用例验证 `document.activeElement`）

### 3. 语义化
- [ ] 优先使用原生语义元素而非 `div` + 大量 ARIA 模拟
- [ ] 自定义交互组件补充必要 ARIA：角色（role）、状态（aria-selected/aria-expanded/aria-disabled）、列表类补充位置信息（aria-posinset/aria-setsize）
- [ ] 表单控件的视觉 label 与实际控件通过 `for`/`aria-labelledby` 关联，不是仅视觉上靠近

### 4. 媒体
- [ ] 图片类内容有 `alt`；图标+文字组合按钮的图标部分不重复 alt
- [ ] 音视频内容有字幕/文字轨道支持点

### 5. 动画安全性
- [ ] 动画/闪烁频率不超过 3 次/秒
- [ ] 若是持续更新内容（流式文本等），`aria-live` 策略默认 `polite`，避免过度打断屏幕阅读器朗读

### 6. 缩放与布局
- [ ] 200% 浏览器缩放下功能完整、内容可读
- [ ] 长内容有结构化分段，不是无结构长段落

## 常见组件类型的重点检查项

- **浮层类（Popover/Dropdown/Tooltip/Modal/SideSheet/Popconfirm）**：焦点陷阱（Modal/SideSheet 必须）、焦点归还、Esc 关闭是重灾区，逐项 Playwright 验证。
- **表单类（Input/Select/Checkbox/Radio/DatePicker）**：label 关联、错误提示与控件的 `aria-describedby` 关联。
- **拖拽/滑动类（Slider/DragMove/Resizable）**：必须提供键盘等价操作（方向键调整数值），不能只支持鼠标拖拽。
- **列表/表格类（Table/Tree/Select 虚拟化）**：虚拟化不能破坏语义结构，滚动到的内容仍需可被屏幕阅读器正确读到 posinset/setsize 信息。

## 自动化兜底

CI 中集成 axe-core 的 Playwright 集成作为自动化扫描兜底，但**不能替代上述人工 checklist**——自动化工具能查出的问题集有限（对比度、部分 ARIA 缺失），焦点管理、键盘操作完整性、动画安全性这类行为性问题仍需人工/Playwright 用例验证。

## 验收标准

对照 `specs/cross-cutting/a11y.spec.md` 「验收标准」小节逐项自检完成后，方可在对应 Phase SPEC 的组件清单打勾。
