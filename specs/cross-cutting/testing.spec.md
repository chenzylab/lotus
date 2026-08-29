# 横切能力 SPEC — 测试策略

> 设计依据：`specs/references/semi-design-articles.md` 「UITest」一节的分工思路（单元/E2E/视觉回归三层职责分离），工具链替换为 Vitest + Playwright（原因：Ripple 非 VDOM 框架，Enzyme 类工具不适用；Vite 生态原生集成 Vitest；Playwright 一套工具同时覆盖 E2E 交互与视觉回归，减少工具链数量）。

## 分层职责（不允许职责错位）

### Vitest — Foundation 层单元测试
- 覆盖对象：`packages/foundation/**/*.ts` 中的状态机、纯逻辑函数、算法（日期计算、色彩算法、虚拟滚动位置计算等）
- 要求：**不 import 任何 `ripple`/`@lotus/ripple` 代码**，通过 mock 一个满足 `Adapter` 接口的假宿主对象来测试 Foundation 类
- 覆盖场景：受控/非受控模式、边界值（空数据/超大数据/异常输入）、状态机的每个转移路径

### Playwright — 真实浏览器交互测试
- 覆盖对象：Foundation 单测无法覆盖的部分——真实布局计算（弹层定位、`getBoundingClientRect`）、真实键盘/鼠标事件序列、跨组件协作（如 Form 内多个字段联动）、焦点管理、动画完成后的最终状态
- 不重复覆盖 Foundation 已单测过的纯逻辑分支（如 Foundation 已测过"disabled 状态下 handleClick 不触发回调"，Playwright 不需要再测一遍同样的分支，只需测"disabled 状态下真实点击 DOM 元素确实无响应"这类需要真实 DOM 的部分）

### Playwright 视觉回归
- 覆盖对象：组件默认态 + 关键状态（hover/active/disabled/error）的截图快照对比
- 每个组件至少 1 张默认态快照；有明显视觉状态分支（如 Button 的 5 种 type × 3 种 size）的组件按矩阵覆盖关键组合，不要求穷举笛卡尔积

## 覆盖率目标

- Foundation 层：语句覆盖率目标 ≥ 85%（对齐 Semi 记录的 86.5% 水平，作为参照而非硬性抄数字）
- 不对 Adapter 层（`.tsrx` 文件）强制要求覆盖率数字，因为其价值更多由 Playwright 交互测试和视觉快照体现，重复用行覆盖率衡量意义不大

## CI 集成

- Vitest 与 Playwright 并行执行（互不阻塞）
- Foundation 覆盖率报告产出（如 `v8` provider），失败阈值触发 CI 红
- Playwright 视觉快照 diff 需要人工审核通过后才能合并（首次生成快照时需明确标注为 baseline，后续变更需要显式更新 baseline 并在 PR 中说明变更原因，防止"悄悄改样式改坏了却更新快照掩盖"）

## 验收标准

- [x] 每个组件的 Foundation（若存在）有对应 `.test.ts`，覆盖率达标——核实 `packages/foundation/src` 下 70 个 `foundation.ts` 里 69 个已有对应 `.test.ts`，唯一缺失的 `show/sidebar/foundation.ts` 是纯重导出汇总文件（真正逻辑拆在同目录 `container-machine.ts`/`code-content.ts`/`mcp-configure.ts`/`main.ts` 里，均已各自有测试），其中 `file-item.ts` 的 `defaultMenuBarActiveState()` 此前遗漏测试已补上，`annotation.ts`/`file-content.ts` 是纯类型定义无需测试。覆盖率此前从未真正测量过（`@vitest/coverage-v8` 依赖未安装），现已安装并新增 `packages/foundation/vitest.config.ts` 设置语句覆盖率阈值 85%，实测 89.33%（4104/4594），达标
- [ ] 每个组件至少 1 条 Playwright 交互测试 + 1 张视觉快照——交互测试部分已大量覆盖（`e2e/` 下 81 个 spec 文件对应 82 个组件目录），但视觉快照（`toHaveScreenshot`）在全仓库 0 处使用，是完全未落地的系统性缺口，用户已确认本次不处理，留待后续专门安排
- [x] CI 中 Vitest 与 Playwright 均为必过项，不允许跳过——核实 `.github/workflows/ci.yml` 的 `Unit test`/`Run e2e tests` 均为普通 step，无 `continue-on-error`/跳过标记，任一失败整个 job 即红；新增 `Foundation coverage` step 接入覆盖率阈值门禁（`pnpm --filter @lotus/foundation run test:coverage`，故意调高阈值验证过退出码确实非 0）
- [ ] 视觉快照 baseline 变更历史可追溯（git diff 能看出哪次提交更新了哪些快照及原因）——依赖上一条"每个组件至少 1 张视觉快照"，该基础设施尚不存在，无从谈起可追溯性，同样留待后续处理
