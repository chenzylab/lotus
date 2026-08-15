---
name: testing
description: 为组件编写 Vitest 单测（Foundation 层）或 Playwright 测试（交互/视觉回归）时使用。定义两者的职责边界，避免重复覆盖或遗漏。对照 specs/cross-cutting/testing.spec.md 执行。
---

# testing

## 何时使用

组件/Foundation 模块实现完成后，进入测试编写阶段；或修改现有逻辑后需要补充回归测试。

## 分层职责判断（先判断该写哪层，再动手）

**这段逻辑要不要写 Foundation 单测？**
- 是纯逻辑/状态机/算法，不涉及真实 DOM → 写 Vitest 单测
- Foundation 已存在但没测试覆盖 → 补测试优先于写新功能

**这个场景要不要写 Playwright？**
- 涉及真实布局计算（弹层定位、`getBoundingClientRect`）→ 需要 Playwright（JSDOM 无法提供真实布局）
- 涉及真实键盘/鼠标事件序列、跨组件协作、焦点管理 → 需要 Playwright
- Foundation 单测已经覆盖的纯逻辑分支（如"disabled 时不触发回调"）→ 不要在 Playwright 里重复测同样的分支判断，只需验证"真实点击 disabled 的 DOM 元素确实无响应"这一条，不需要穷举所有 disabled 相关的逻辑分支

## Vitest 单测编写规范

```ts
// packages/foundation/src/<category>/<component>/foundation.test.ts
import { describe, it, expect, vi } from 'vitest';
import { XxxFoundation } from './foundation';

function createMockAdapter(initialState) {
  let state = initialState;
  return {
    getState: () => state,
    setState: (patch) => { state = { ...state, ...patch }; },
    _getRawState: () => state, // 测试专用，读取内部状态做断言
  };
}

describe('XxxFoundation', () => {
  it('disabled 状态下点击不触发回调', () => {
    const adapter = createMockAdapter({ disabled: true });
    const foundation = new XxxFoundation(adapter);
    const onClick = vi.fn();
    foundation.handleClick(onClick);
    expect(onClick).not.toHaveBeenCalled();
  });
});
```

**红线**：测试文件不 import 任何 `ripple`/`@lotus/ripple` 代码，`createMockAdapter` 全部用 plain object 手写。若发现某个 Foundation 的测试必须依赖 Ripple 才能跑，说明该 Foundation 的接口设计有问题（可能不小心耦合了框架细节），回头调用 `foundation-authoring` skill 重新审视。

## Playwright 测试编写规范

- 测试文件放在 `e2e/<category>/<component>.spec.ts`，与 `packages/ripple/src` 的分类目录一一对应。
- 交互测试针对 `apps/playground` 或 `apps/docs` 中该组件的示例页面，不要为测试单独搭一套隔离的最小 HTML（复用真实文档示例，保证测试环境与用户实际使用环境一致）。
- 视觉快照：默认态必须有；有明显视觉分支（type/size 等）的组件按关键组合截图，不强求穷举笛卡尔积。
- 首次生成的快照标记为 baseline；后续变更快照需在 PR 描述中说明原因，防止样式改坏被"更新快照"掩盖（对应用户全局原则「诚实报错」）。

## 覆盖率与 CI

- Foundation 层语句覆盖率目标 ≥ 85%（用 `vitest run --coverage`）。
- CI 中 Vitest 与 Playwright 并行跑，均为必过项。若因环境限制需跳过，必须在 PR 中明确说明并给出后续补测计划，不能静默跳过。

## 验收标准

对照 `specs/cross-cutting/testing.spec.md` 「验收标准」小节：Foundation 单测存在且达标、至少 1 条 Playwright 交互测试 + 1 张视觉快照、CI 全绿。
