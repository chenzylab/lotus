---
name: foundation-authoring
description: 为组件设计框架无关的 Foundation 状态机/逻辑层时使用。定义 Foundation/Adapter 依赖注入模式、何时该拆 Foundation、如何写可独立单测的纯逻辑类。
---

# foundation-authoring

## 何时使用

组件存在非平凡状态机时：受控/非受控双模式、键盘导航、异步校验、多步骤流程、需要复用的算法（虚拟滚动、浮层定位、拖拽跟踪、色彩/日期计算）。**纯展示组件（Divider/Space/Grid 等）不需要 Foundation，直接在 Adapter 层实现即可**，不要为了架构一致性强行拆分空壳 Foundation。

## 核心模式：Foundation / Adapter 依赖倒置

参照 Semi 的 F/A 架构思路（见 `specs/references/semi-design-articles.md` 「FA」一节），但注意 lotus 只有一个目标框架（Ripple），拆分的意义在于可单测性与未来可能的多目标复用，不是当前就要支持多框架。

**关键原则：Foundation 不 import Ripple，Adapter 把自己的能力通过一个接口对象注入给 Foundation。**

```ts
// packages/foundation/base/adapter.ts
export interface Adapter<S> {
  getState: () => S;
  setState: (patch: Partial<S>) => void;
  // 组件特定的宿主能力，按需扩展
}

// packages/foundation/src/basic/button/foundation.ts
import type { Adapter } from '../base/adapter';

interface ButtonState {
  loading: boolean;
  disabled: boolean;
}

export class ButtonFoundation {
  constructor(private adapter: Adapter<ButtonState>) {}

  handleClick(onClick?: () => void) {
    const { loading, disabled } = this.adapter.getState();
    if (loading || disabled) return;
    onClick?.();
  }
}
```

```tsrx
// packages/ripple/src/basic/button/index.tsrx —— Adapter 层实现
import { track } from 'ripple';
import { ButtonFoundation } from '@lotus/foundation/basic/button';

export function Button({ children, onClick, disabled, loading }: ButtonProps) @{
    let &[state] = track({ disabled: !!disabled, loading: !!loading });
    const foundation = new ButtonFoundation({
        getState: () => state,
        setState: (patch) => { state = { ...state, ...patch }; },
    });

    <button class="lotus-button" onClick={() => foundation.handleClick(onClick)}>
        {children}
    </button>
}
```

**Phase 0 必须先用 Button 验证这个模式在 Ripple 的 `track()` 响应式模型下是否顺畅**（尤其是 Foundation 读取的 state 是否能正确触发依赖追踪），验证结论记录在 `specs/cross-cutting/foundation-adapter-pattern.md`。后续所有组件的 Foundation 实现都follow 该文档确认过的范式，不要每个组件重新摸索。

## 何时该抽公共 Foundation

多个组件出现相同的状态机/算法时（如浮层定位被 Popover/Dropdown/Tooltip/Popconfirm 共用），下沉到 `packages/foundation/base/` 作为独立模块，被各组件的 Foundation 或 Adapter 引用。抽取前用 `grep` 确认真的有 2+ 处重复实现，不要预先设计"可能用得上"的抽象。

## 单测要求

- 每个 Foundation 类/模块必须有对应 `foundation.test.ts`，用 Vitest。
- 测试中手写一个满足 `Adapter` 接口的假对象（plain object + 闭包变量模拟状态），**不 import 任何 `ripple` 包**——这是验证 Foundation 真正框架无关的红线检查。
- 覆盖场景：状态机的每个转移路径、边界值（空/超大数据/异常输入）、受控与非受控模式的行为一致性。

## 常见坑

- 不要在 Foundation 里操作 DOM（`document.querySelector` 等），DOM 操作永远属于 Adapter。
- 不要让 Foundation 直接持有 Ripple 的 `Tracked` 对象类型作为强依赖——用接口抽象掉具体的响应式实现，Foundation 只依赖 `getState`/`setState` 这类平凡函数签名。
- 异步逻辑（防抖、节流、定时器）如果和框架生命周期强相关（组件卸载时清理），清理动作属于 Adapter 职责（Ripple 的 `effect()` 返回清理函数），但清理"要做什么"的逻辑本身可以下沉 Foundation。
- **Foundation 的 `init()` 类初始化方法若在内部同步调用多次 `setState`（如订阅多个断点、批量注册监听器），Adapter 侧调用它时必须用 `untrack()` 包裹**（`untrack(() => foundation.init())`），且 `getState` 的实现本身也应该是 `() => untrack(() => state)`。否则如果这个初始化调用发生在 `effect(() => {...})` 内部，其内部的读写会被记入该 effect 的响应式依赖，导致"写入触发 effect 重跑 → 重新初始化 → 再次写入"的无限循环，Ripple 运行时会在 1000+ 次后报错 `Maximum update depth exceeded`。这是 Phase 1 Grid 组件（Row 的响应式断点检测）实测踩过的坑，完整范式代码见 `specs/cross-cutting/foundation-adapter-pattern.md` 踩坑 #7。
- **Foundation 计算出的值如果要被其他组件（通过 Context 或 props）消费、且需要随源状态变化而更新，Adapter 侧不能用一次性的普通 `const`/赋值语句包装这个计算结果**——必须用 `let &[x] = track(() => ...)` 派生绑定。`.tsrx` 组件的 setup 代码只在组件创建时执行一次，普通变量赋值不会因为源头 state 变化而重新执行，这与其他框架"整个组件函数每次渲染重跑"的心智模型不同，从其他框架经验迁移时最容易在这里出错。
