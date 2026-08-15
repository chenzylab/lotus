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

- [ ] 任意面向用户的文案字符串搜索（`grep` 中文/英文硬编码字符串于 `packages/ripple/src` 下）应为零命中（测试/注释除外）
- [ ] Form 组件切换 locale 后，校验错误文案实时更新（不需要重新挂载组件）
- [ ] DatePicker/Calendar 的月份名称、周起始日在切换到日语/阿拉伯语 locale 后正确显示，且阿拉伯语场景下整体布局镜像（非文案本身镜像，是布局方向）
- [ ] RTL 模式下方向性图标（如 Breadcrumb 分隔箭头、Collapse 展开箭头）视觉上正确翻转
- [ ] 新增语言包时不需要修改任何组件代码（纯数据层扩展），作为架构正确性的反向验证
