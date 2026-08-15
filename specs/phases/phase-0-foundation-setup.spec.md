# Phase 0 — 工程基建

> 前置于所有组件开发。目标：monorepo 可跑通「改一行 tsrx 代码 → Vite 热更新 → Vitest/Playwright 可测」的最小闭环，且 Token/Foundation/Adapter 三层依赖关系被一个真实的 Demo 组件（Button）验证过，而不是纸面设计。

## 目标

1. pnpm workspace 初始化，`packages/*` 与 `apps/*` 能互相 `workspace:*` 引用。
2. `@lotus/tokens` 产出可用的 CSS 变量文件（哪怕第一版只有色彩 + 圆角 + 间距三类）。
3. `@ripple-ts/vite-plugin` 在 `apps/playground` 里跑通，能渲染一个 `.tsrx` 组件并热更新。
4. 用 Button 组件走通 Foundation → Adapter 依赖注入模式，验证 F/A 分层在 Ripple 下是否顺畅（`track()` 状态如何注入 Foundation 是本阶段最大的技术不确定性，必须先验证再铺开其他组件）。
5. Vitest 跑通 Foundation 单测；Playwright 跑通一条针对 Button 的交互测试。
6. ESLint/Prettier 对 `.tsrx` 文件的解析可用（确认 tsrx 官方是否提供 ESLint parser/plugin，若无则先只 lint `.ts`/`.tsx` 文件，`.tsrx` 格式化留到后续）。

## 范围

**包含**：
- `pnpm-workspace.yaml`、根 `package.json`、`tsconfig.json`（base + 各包继承）
- `packages/tokens`：色彩算法脚本（品牌色 → 色阶，先实现最简版本，不要求一次到位复刻 Semi 的 HSB 精细算法）、构建产出 `dist/tokens.css`
- `packages/foundation`：`src/base/` 目录下定义通用 `Foundation` 基类和 `Adapter` 接口（TS interface，描述 Foundation 期望宿主提供的 getter/setter），`src/basic/button/foundation.ts` 作为首个具体实现（`basic` 是 Button 所属的 Semi 官方分类，见 AGENTS.md「组件分类目录」一节，本阶段起所有组件路径均遵循该分类结构）
- `packages/ripple`：`src/basic/button/index.tsrx`，消费 `@lotus/tokens` 的 CSS 变量与 `@lotus/foundation` 的 `ButtonFoundation`
- `apps/playground`：最小 Vite + Ripple 应用，渲染 Button
- `e2e/button.spec.ts`：Playwright 首条测试
- CI：GitHub Actions 跑 `pnpm build && pnpm test && pnpm test:e2e`

**不包含**：文档站（`apps/docs`）搭建、其他任何组件、CLI 工具、发布流程实操（走查一遍即可，不要求真发布到 npm）。

## 依赖 Skill

- `component-authoring`（走一遍最小实现路径）
- `foundation-authoring`（定义 `Adapter` 接口的模式）
- `theme-tokens`（Token 产出格式）
- `testing`（Vitest + Playwright 最小配置）

## 验收标准

- [x] `pnpm install && pnpm -r build` 在干净环境下成功（实测：`rm -rf packages/*/dist apps/*/dist && pnpm install && pnpm -r build`，4/5 有 build 脚本的包全部成功）
- [x] `pnpm --filter @lotus/playground dev` 启动后浏览器可见一个可点击的 Button，点击触发 `console.log`（证明事件绑定链路通）（实测：Chrome 真实渲染 + 点击，`read_console_messages` 捕获到 `lotus button clicked`）
- [x] Button 的 hover/active/disabled 视觉状态通过 `var(--lotus-color-*)` 驱动，修改 `packages/tokens` 源文件后重新构建，Button 视觉随之变化（证明 Token → Adapter 消费链路通）（实测：品牌色由蓝改绿并重新构建，Chrome 截图确认按钮视觉同步变绿，随后已复原）
- [x] `ButtonFoundation` 类中至少一个方法（如 `handleClick` 处理 disabled/loading 拦截逻辑）有 Vitest 单测，且该测试**不 import 任何 `ripple` 包**（证明 Foundation 真正框架无关）（实测：4 个用例全部通过，`grep ripple` 红线检查命中为零）
- [x] `pnpm test:e2e` 跑通至少一条 Playwright 用例，验证点击 disabled 状态的 Button 不触发回调（实测：3 条用例全部通过，含 disabled/loading 两种拦截场景）
- [x] 记录本阶段验证出的 F/A 注入模式（Foundation 如何拿到 Ripple 的 `track()` state）到 `specs/cross-cutting/foundation-adapter-pattern.md`（新建），作为后续所有组件实现的范式参考——**这是本阶段最重要的产出物**，其价值高于 Button 组件本身（已完成，含范式代码 + 6 条实测踩坑记录）
- [x] ESLint/Prettier 对 `.tsrx` 文件的解析可用（目标 6，原验收标准遗漏，走查时补充）：`@tsrx/eslint-plugin` + `@tsrx/eslint-parser` + `@tsrx/prettier-plugin` 均已接入并实测通过（`pnpm lint` 全项目零错误，`prettier --write` 成功格式化 `.tsrx` 文件且格式化后仍能通过 build/typecheck/e2e）

## 风险与决策点（回填实测结论）

- ~~Ripple/tsrx 生态是否有官方 ESLint 支持未知~~ → **已确认**：官方提供 `@tsrx/eslint-plugin`（Flat Config，`ripple.configs.recommended`）+ `@tsrx/eslint-parser` + `@tsrx/prettier-plugin`，用法与 `eslint-plugin-react` 类似。唯一障碍是 `@typescript-eslint/parser` 尚不支持 TypeScript 7.0（生态断层，非本项目问题），已用官方 `@typescript/typescript6` 兼容包在根级单独解决，不影响子包。详见 `foundation-adapter-pattern.md` 踩坑 #6。
- Foundation 依赖注入模式若在 Ripple 的细粒度响应式模型下有摩擦 → **已确认无摩擦**：`track()` 状态可直接闭包捕获传给 Foundation 构造函数，`getState`/`setState` 简单转发即可，浏览器实测三态（default/disabled/loading）行为均正确。详见 `foundation-adapter-pattern.md`。
- **新发现的风险（原 SPEC 未预料）**：tsrx 生态整体对 TypeScript 7.0 支持不完整——`@tsrx/typescript-plugin`（peer 要求 `^5.9.3`）和 `@typescript-eslint/parser`（不支持 `7.0.x`）都要求独立锁定旧版 TypeScript，导致本项目出现三套并存的 TypeScript 版本（根级 ESLint 用 6.0.2 别名、无 tsrx 依赖的包用 7.0.2、直接消费 `.tsrx` 的包用 5.9.3）。这是当前 tsrx 生态成熟度的真实约束，非工程配置失误，已在 `foundation-adapter-pattern.md` 完整记录三者的边界与理由，后续新增包时需按该文档的规则选择正确的 TypeScript 版本来源，不要凭空决定。
