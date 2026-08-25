# Phase 1 — 基础层 + 核心表单

> 依赖：Phase 0 已完成（F/A 注入模式已验证）。
> 组件清单见 `specs/component-inventory.md` 「Phase 1」小节，本文件不重复列表，只定义该阶段的目标、范围与验收标准。开发时逐项勾选清单文件，不在本 SPEC 内维护进度。

## 目标

搭起 lotus 的视觉基础设施（Icon/Typography/Grid/Layout/Space/Divider）与最常用的原子级表单控件（Input/InputNumber/Checkbox/Radio/Switch），并交付 Form —— 组件库中第一个「组合型」组件，验证表单校验/受控-非受控模式在 Ripple 下的实现范式。

## 范围

- **纯展示类**（Divider/Space/Grid/Layout/Typography）：无 Foundation 层，直接在 Adapter 实现，重点是 Token 消费的正确性与响应式布局（Grid 断点）。
- **Icon + IconButton**：`packages/icons` 整包工程启动。图标资产移植自 `~/i/semi-design/packages/semi-icons`（523 个）+ `semi-icons-lab`（84 个），SVG 源文件（纯图形资产，MIT License）可直接复用，生成 tsrx 组件的构建脚本参考 Semi 的 `build-svg.js` 思路自研（目标模板从 React `.tsx` 改为 tsrx），详细移植规范见 `specs/component-inventory.md`「图标资产移植」一节与 `semi-porting` skill；IconButton 复用 Icon + Button 的组合。
- **FloatButton**：含 AI 主题变体（对应官网 AIFloatButton），此时 `theme-tokens` 的 AI 渐变色变量必须已就绪。
- **原子表单控件**（Input/InputNumber/Checkbox/Radio/Switch）：均需要 Foundation 层，处理受控/非受控双模式、`onChange` 语义、键盘可达性。这是本阶段 Foundation 设计的重点练习对象。
- **Form**：依赖上述所有表单控件；需要设计 Foundation 层的表单级状态管理（字段注册、校验触发时机、错误信息聚合）。Form 的复杂度显著高于其他组件，允许单独排更多时间。

## 依赖 Skill

`component-authoring`、`foundation-authoring`、`theme-tokens`、`i18n-locale`（Form 校验错误文案）、`a11y-audit`（表单控件的 label 关联、键盘操作是本阶段 a11y 重灾区）、`testing`

## 验收标准

- [ ] 清单文件中 Phase 1 全部条目勾选，且每项满足 AGENTS.md 第 3 节 DoD
- [ ] Grid 组件在至少 3 个断点下的响应式行为有 Playwright 视觉快照覆盖
- [ ] Icon 包支持按需引入单个图标（不因为引入一个图标打包进全量 SVG），有构建产物体积的 Playwright/脚本级校验
- [ ] `packages/icons` 生成的图标组件数量与源 SVG 数量一致（523 个正式图标 + 84 个 lab 图标，脚本级校验数量匹配，防止生成流程静默跳过部分文件）
- [ ] Input/Checkbox/Radio/Switch 的受控模式（外部传入 `value`/`checked` + `onChange`）与非受控模式（`defaultValue`/`defaultChecked`）均有 Foundation 单测覆盖，两种模式行为一致性是常见 bug 来源，需专项测试
- [x] Form 的字段校验支持同步和异步校验器，错误信息展示时机（blur/change/submit）可配置，有 Foundation 单测覆盖状态机的至少 5 种场景（必填/异步校验中/校验失败/校验通过/字段联动）——重新核实后发现"异步校验中"和"字段联动"两条实际情况与预期不同：Semi 自身异步校验期间也不暴露 validating 状态（`validateStatus` 只有 error/warning/default/success），lotus 主动新增 `FormState.validating` 超越 Semi；"字段联动"Semi 无专门 API，官方文档写的是"监听 onChange + 手动 formApi.setValue"，lotus 现有 `formApi.setValue` 已完全支持，本次补充 demo+e2e 验证。必填/校验失败/校验通过三种场景此前已有单测覆盖
- [x] Form 的错误提示文案通过 `@lotus/locale` token 输出，不硬编码语言
- [ ] 所有表单控件键盘可完全操作（Tab 聚焦、Space/Enter 激活），并有对应 Playwright 键盘操作用例
- [ ] FloatButton 的 AI 主题变体视觉通过 `.claude/skills/theme-tokens` 的对比度检查
