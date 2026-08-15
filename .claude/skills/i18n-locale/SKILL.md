---
name: i18n-locale
description: 组件涉及用户可见文案（错误提示、占位符、按钮文案、日期/数字格式化）时使用。确保文案走 @lotus/locale token 而非硬编码，并符合 RTL 布局要求。对照 specs/cross-cutting/i18n-locale.spec.md 执行。
---

# i18n-locale

## 何时使用

任何组件包含面向用户的文本（不是开发者可见的 prop 名/类名）时，编码前先规划该文案如何走 locale token，而不是先硬编码中文/英文再回头改。

## 操作步骤

1. **确认文案命名空间**：在 `packages/locale/src/<lang>.ts` 中按组件分类组织 key（如 `locale.Form.required`、`locale.DatePicker.today`），不要用扁平全局 key（如 `required_field_error`），命名空间避免大型语言包冲突和难以定位。
2. **组件内消费**：通过 ConfigProvider 提供的 locale 上下文读取文案，不在组件内直接 `import zhCN from './zh-CN'` 写死语言。
3. **新增文案 key 时同步补齐所有已支持语言**：至少中文简体 + 英文必须同步，缺失的语言先留 TODO 标记但不能让运行时报错或显示 undefined。
4. **格式化类需求**（日期/数字/货币）调用 `@lotus/locale` 暴露的格式化函数，不在组件里手写字符串拼接格式化逻辑。

## RTL 检查清单（涉及方向性布局/图标的组件必查）

- [ ] 间距/定位属性使用逻辑属性（`margin-inline-start`/`inset-inline-end`），不用物理属性（`margin-left`/`right`）
- [ ] 方向性图标（箭头、展开/收起指示符）在 RTL 模式下提供镜像变体或用 CSS `transform: scaleX(-1)` 配合逻辑判断
- [ ] 文本对齐、Flex/Grid 排列方向不假设从左到右

## 自检：硬编码文案扫描

组件实现完成后执行：
```bash
grep -rP '[\x{4e00}-\x{9fff}]' packages/ripple/src/<category>/<component>/*.tsrx
```
（检测组件源码中残留的中文硬编码字符；英文硬编码用人工审查捕捉常见词如 "Submit"/"Cancel"/"Loading"）预期结果应为零命中（测试文件、注释除外）。

## 验收标准

对照 `specs/cross-cutting/i18n-locale.spec.md` 「验收标准」小节逐项自检，重点关注"切换 locale 后组件无需重新挂载即可更新"这一条——这是检验 locale 消费方式是否正确（响应式读取 vs 一次性读取）的关键测试。
