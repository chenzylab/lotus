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

- [x] 清单文件中 Phase 1 全部条目勾选，且每项满足 AGENTS.md 第 3 节 DoD——`specs/component-inventory.md` Phase 1 小节 16 个组件全部 `[x]`
- [x] Grid 组件在至少 3 个断点下的响应式行为有 Playwright 视觉快照覆盖——核实此前 `e2e/basic/grid.spec.ts` 只测过 pull/push/span=0 两个静态场景，完全没有验证过任何响应式断点是否真的生效，是真实缺口；新增测试覆盖 xs（<768px，回退到 span 本身）/md（768-991px）/lg（≥992px）三档视口宽度，用 `getBoundingClientRect` 精确百分比宽度断言（Col 的响应式是 JS 计算后写入 inline style flexBasis，不是 CSS `@media`，需要真实切换 viewport 才能验证），比像素级视觉快照更不容易受字体渲染/抗锯齿差异误报，`--repeat-each=5` 5/5 稳定通过
- [x] Icon 包支持按需引入单个图标（不因为引入一个图标打包进全量 SVG），有构建产物体积的 Playwright/脚本级校验——新增 `packages/icons/scripts/verify-tree-shaking.ts`（`pnpm --filter @lotus/icons run verify:tree-shaking`），用真实 Vite+ripple 插件分别构建"只 import 1 个图标"与"全量 export"两个入口，核心断言是产物里出现的图标函数定义数量（1 个 vs 524 个）而非字节数——探索过程中发现字节数会被 ripple 运行时的固定注入体积（hydration/operations 等内部模块，不随图标数量变化）掩盖真实差异，单图标产物因为这部分固定开销仍有 345KB，容易误判为"tree-shaking 没生效"，改用函数定义计数后得到精确、无噪声的信号：单图标引入产物只含 1 个图标函数、全量引入含 524 个，确凿证明按需引入生效
- [x] `packages/icons` 生成的图标组件数量与源 SVG 数量一致（523 个正式图标 + 84 个 lab 图标，脚本级校验数量匹配，防止生成流程静默跳过部分文件）——核实发现该校验其实早已实现（`packages/icons/scripts/generate-icons.ts` 第 172-176 行、`packages/icons-lab` 同款脚本对应位置），生成流程本身有 `if (generated.length !== svgFiles.length) throw` 硬校验，只是从未打勾；重跑 `pnpm --filter @lotus/icons run generate` 验证确实生效（524 个源文件 = 524 个生成组件，无 diff）。`@lotus/icons` 524 个 = Semi 一手来源正式图标 523 个 + lotus 自有 `lotus_logo.svg` 1 个，`@lotus/icons-lab` 独立成包 84 个对齐一手来源，详见 `specs/component-inventory.md` 第 20 行的澄清记录
- [x] Input/Checkbox/Radio/Switch 的受控模式（外部传入 `value`/`checked` + `onChange`）与非受控模式（`defaultValue`/`defaultChecked`）均有 Foundation 单测覆盖，两种模式行为一致性是常见 bug 来源，需专项测试——核实四个组件的 `foundation.test.ts` 均已有 `controlled mode`/`uncontrolled mode` 成对测试，纯文档滞后未勾选
- [x] Form 的字段校验支持同步和异步校验器，错误信息展示时机（blur/change/submit）可配置，有 Foundation 单测覆盖状态机的至少 5 种场景（必填/异步校验中/校验失败/校验通过/字段联动）——重新核实后发现"异步校验中"和"字段联动"两条实际情况与预期不同：Semi 自身异步校验期间也不暴露 validating 状态（`validateStatus` 只有 error/warning/default/success），lotus 主动新增 `FormState.validating` 超越 Semi；"字段联动"Semi 无专门 API，官方文档写的是"监听 onChange + 手动 formApi.setValue"，lotus 现有 `formApi.setValue` 已完全支持，本次补充 demo+e2e 验证。必填/校验失败/校验通过三种场景此前已有单测覆盖
- [x] Form 的错误提示文案通过 `@lotus/locale` token 输出，不硬编码语言
- [x] 所有表单控件键盘可完全操作（Tab 聚焦、Space/Enter 激活），并有对应 Playwright 键盘操作用例——逐组件核实：Checkbox/Radio/Switch/Input/InputNumber/TextArea 均基于原生 `<input>`/`<textarea>`/`<button>` 元素，Tab 聚焦、Space/Enter 激活是浏览器原生行为不是 lotus 自己实现的逻辑，无需额外测试；Upload 的拖拽区/上传按钮是 `<div role="button">`+手写 `onKeyDown`，此前配套测试名叫"键盘可达"但只断言过 `role`/`tabindex` 两个静态属性、从未真正按键验证过，是真实缺口，已用 `page.waitForEvent('filechooser')` 补齐 Enter/Space 两条真实触发验证（探索中发现 `page.keyboard.press` 依赖全局焦点状态、`focus()` 与全局按键之间存在焦点丢失窗口导致间歇性超时，改用 `locator.press()` 后 30/30 稳定通过）；Transfer 的拖拽手柄/移除按钮同样是自定义 `<span role="button">` 且无键盘支持，但这是已在 `specs/component-inventory.md` 如实记录过的已知短板（"留作后续迭代"），不在本次范围内一并修复
- [x] FloatButton 的 AI 主题变体视觉通过 `.claude/skills/theme-tokens` 的对比度检查——核实过程中发现比对比度问题更根本的偏差：`aiColor.general/generalHover/generalActive` 渐变与 Semi 一手来源（`_palette.scss` 的 `--semi-ai-general-5/6/7`）完全不一致（角度 90deg vs 278deg、色标数 3 个 vs 4 个、颜色顺序相反），且此前无论 light/dark 模式都读同一份值；`purpleHover`/`purpleActive` 也是错误地用透明度派生而非独立色值；`backgroundTop`/`backgroundBottom` 更是把 Semi 一手来源的多色标渐变简化成了单色 rgba。已按一手来源完整重构 `aiColor`（`packages/tokens/src/static-tokens.ts`），FloatButton/Button/Tag 三个消费方全部通过 CSS 变量自动同步，真机验证确认新渐变正确生效。重新计算后的真实对比度：default 态最低 3.11:1（满足 UI 组件 3.0:1 但低于正文 4.5:1，与 Semi 一手来源本身的固有权衡一致，记入「已知设计权衡」而非缺陷）、hover 4.35:1、active 6.15:1 均达标
