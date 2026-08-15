---
name: component-authoring
description: 从零实现或重写一个 lotus Ripple 组件（Adapter 层）时使用。定义 .tsrx 编码规范、目录结构、Token 消费方式与新组件的 Definition of Done 检查清单。
---

# component-authoring

## 何时使用

新增或重写 `packages/ripple/src/<component>/` 下的组件实现时。**先看该组件是否存在于 `specs/component-inventory.md` 及对应 Phase SPEC**，确认范围与验收标准，再动手。

## 前置阅读

- `specs/references/tsrx-llms.txt`、`specs/references/ripple-llms.txt`：语法与运行时 API 唯一权威来源。不要凭 React/Vue 经验猜测 tsrx 语法。
- `specs/cross-cutting/foundation-adapter-pattern.md`「已知踩坑」：实测踩过的坑，新组件/新包开工前必看，尤其是：
  - Fragment 包裹规则（#1）、`.tsrx` 类型检查必须用 `tsrx-tsc` 而非 `tsc`（#5）
  - **组件间共享响应式状态（Context、跨组件联动）时的响应式陷阱（#7）**——`.tsrx` 组件 setup 阶段的普通变量赋值只执行一次、不是响应式的；Context 必须传 `Tracked` 对象本身而非解构出的 plain object；计算值若要跟随源头响应式变化，必须用 `let &[x] = track(() => ...)` 派生绑定，不能用普通 `const`；`effect()` 内部的一次性初始化副作用需要 `untrack()` 包裹避免依赖循环。这是 Phase 1 Grid 组件排查耗时最长的一类 bug，涉及父子组件协作的组件（Row/Col、Tabs、Form 等）大概率会重新踩到，务必先读完这条踩坑记录里的完整范式代码。
- 若组件需要 Foundation 层（非纯展示组件），先调用 `foundation-authoring` skill。

## 目录结构约定

组件目录按 Semi 官方分类组织在 `packages/ripple/src/<category>/<component>/` 下（分类为 `basic`/`navigation`/`input`/`show`/`feedback`/`other`/`plus`/`ai`，完整映射见 AGENTS.md 「组件分类目录」一节和 `specs/component-inventory.md`）。开工前先确认该组件属于哪个分类，不要新建分类或放错目录。

```
packages/ripple/src/<category>/<component>/
├── index.tsrx          # 主实现，导出组件函数
├── index.ts             # 类型 + re-export（若需要拆分 Props 类型定义）
└── <component>.scss     # 若样式复杂到不适合内联 <style>（罕见，优先用 scoped <style>）
```

例如 Select 属于 `input` 分类：`packages/ripple/src/input/select/index.tsrx`，对应 Foundation 在 `packages/foundation/src/input/select/foundation.ts`。两侧分类路径必须一一对应，import 路径可预测。

## 编码规范（tsrx / Ripple 专属）

- 组件文件用 `.tsrx` 扩展名，导出用 `export function ComponentName(props: Props) { ... }`。
- 单一根节点：直接 `return <div />`，不套多余 Fragment。
- 需要 setup 语句 + 渲染输出共享作用域时，用 `@{ ... }` 语句容器，setup 在前，最后一个节点必须是单个 JSX 元素/Fragment/控制流表达式。**几乎每个组件都同时渲染主内容 + `<style>` 块，这就是两个平级兄弟节点，必须用 `<>...</>` 包裹**，遗漏会在编译期报错 `A code block renders a single node; wrap multiple nodes or text in a fragment`（Phase 0 Button 组件实测踩过，详见 `specs/cross-cutting/foundation-adapter-pattern.md`「已知踩坑」）。
- 响应式状态用 `track()` + lazy destructure（`let &[value, setValue] = track(initial)`），不要引入 Ripple 官方 API 之外的状态管理库。
- 列表渲染用 `@for (... of ...; index i; key ...)`，必须提供 `key`；条件渲染用 `@if/@else if/@else`；不要用裸 JS `if`/`for` 充当模板控制流（tsrx 中这是语法错误，不是风格问题）。
- Ripple/tsrx 目标下 class 用 `class`（不是 React 的 `className`）。
- 样式默认写在组件内的 scoped `<style>` 块中，纯静态 CSS；运行时变化的值通过 CSS 自定义属性（`style={{ '--foo': value }}` + `var(--foo)`）传递，不在 `<style>` 块内写 `{expr}` 或任何 JS 表达式（tsrx 语法不允许）。
- 类名/CSS 变量禁止出现 `semi` 字样，前缀统一 `lotus-`（对应 `theme-tokens` skill 的变量命名规范）。

## Token 消费检查清单

- [ ] 颜色、圆角、间距、阴影、字体全部通过 `var(--lotus-*)` 引用，无硬编码数值（十六进制色值、裸 px 数字）
- [ ] 若组件需要新的语义变量，先调用 `theme-tokens` skill 评估是否已有可复用变量，避免变量膨胀

## 基础交互能力自研原则

浮层定位、拖拽手势、虚拟滚动等交互行为类基础能力，一律在 `packages/foundation/base/` 下自研（不依赖 Floating UI / react-window / interact.js 等第三方运行时库），组件只是消费这些 Foundation 模块。日期计算、Markdown/代码高亮解析等"内容处理"类可以正常使用成熟第三方库。详见 AGENTS.md「基础能力自研」条款。新增此类基础模块前，先 `grep packages/foundation/base` 确认是否已有可复用实现。

## Definition of Done（对照 AGENTS.md 第 3 节，逐项自检）

- [ ] Foundation（若需要）+ 单测已完成
- [ ] Adapter `.tsrx` 实现完成，通过 `pnpm --filter @lotus/playground build`（或 `typecheck`）编译无错——`@lotus/ripple` 本身不做独立构建，是被 Vite/tsrx 插件链在消费方（playground/docs）编译时处理的源码包
- [ ] Props 类型完整导出
- [ ] Token 消费检查清单通过
- [ ] `apps/docs` 至少一个可运行示例
- [ ] Foundation 单测 + 至少一条 Playwright 交互测试（调用 `testing` skill）
- [ ] 过 `a11y-audit` skill 检查清单
- [ ] 文案走 `@lotus/locale`（调用 `i18n-locale` skill）
- [ ] 若为大数据组件，建立性能基线（调用 `perf-baseline` skill）
- [ ] 对应 Phase SPEC 的清单条目已打勾
