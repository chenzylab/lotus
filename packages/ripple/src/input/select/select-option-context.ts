import { Context } from 'ripple';
import type { SelectOptionGroup, SelectOptionOrGroup } from '@lotus/foundation/input/select';

/**
 * 组合式 `<Select.Option>` / `<Select.OptGroup>` 的注册收集机制（对齐 Semi
 * Select.Option / Select.OptGroup children 声明），与配置式 `optionList` prop
 * 并存（`optionList` 非空时优先生效，同 RadioGroup 的 options/children 双写法
 * 惯例）。
 *
 * 移植自 chenzy.design（本仓库姊妹 Svelte 设计系统）已验证可行的方案：子组件
 * 挂载时把自身信息注册进最近的收集器（`<Select.OptGroup>` 内注册进组收集器，
 * 否则注册进 Select 根收集器），Select 本体汇总收集器快照驱动渲染。只有两层
 * ——组收集器只收 Option，不支持分组嵌套分组（对齐 Semi）。
 *
 * register 必须在组件初始化期同步调用（Ripple `Context.get()`/`set()` 依赖
 * `active_component`，只在组件 setup 阶段有效）；update/unregister 在 effect
 * 内（update 每次渲染同步最新 props，cleanup 时 unregister）。
 */

export interface RegisteredSelectOption {
  value: string | number;
  label?: any;
  disabled?: boolean;
}

export interface OptionRegistrar {
  register(data: RegisteredSelectOption): number;
  update(id: number, data: RegisteredSelectOption): void;
  unregister(id: number): void;
}

export interface OptionCollector extends OptionRegistrar {
  snapshot(): RegisteredSelectOption[];
}

export interface RootOptionCollector extends OptionRegistrar {
  registerGroup(label: any): { id: number; collector: OptionCollector };
  updateGroupLabel(id: number, label: any): void;
  unregisterGroup(id: number): void;
  snapshot(): SelectOptionOrGroup<RegisteredSelectOption>[];
}

interface OptionNode {
  id: number;
  data: RegisteredSelectOption;
}

interface GroupNode {
  id: number;
  label: any;
  optionCollector: OptionCollector;
}

type Entry = { kind: 'option'; node: OptionNode } | { kind: 'group'; node: GroupNode };

function createOptionCollector(bump: () => void): OptionCollector {
  const order: OptionNode[] = [];
  let nextId = 0;
  return {
    register(data) {
      const id = nextId++;
      order.push({ id, data });
      bump();
      return id;
    },
    update(id, data) {
      const node = order.find((n) => n.id === id);
      if (!node) return;
      node.data = data;
      bump();
    },
    unregister(id) {
      const i = order.findIndex((n) => n.id === id);
      if (i !== -1) {
        order.splice(i, 1);
        bump();
      }
    },
    snapshot() {
      return order.map((n) => n.data);
    },
  };
}

export function createRootOptionCollector(bump: () => void): RootOptionCollector {
  const entries: Entry[] = [];
  let nextOptionId = 0;
  let nextGroupId = 0;

  return {
    register(data) {
      const id = nextOptionId++;
      entries.push({ kind: 'option', node: { id, data } });
      bump();
      return id;
    },
    update(id, data) {
      const entry = entries.find((e) => e.kind === 'option' && e.node.id === id) as
        | { kind: 'option'; node: OptionNode }
        | undefined;
      if (!entry) return;
      entry.node.data = data;
      bump();
    },
    unregister(id) {
      const i = entries.findIndex((e) => e.kind === 'option' && e.node.id === id);
      if (i !== -1) {
        entries.splice(i, 1);
        bump();
      }
    },
    registerGroup(label) {
      const id = nextGroupId++;
      const optionCollector = createOptionCollector(bump);
      entries.push({ kind: 'group', node: { id, label, optionCollector } });
      bump();
      return { id, collector: optionCollector };
    },
    updateGroupLabel(id, label) {
      const entry = entries.find((e) => e.kind === 'group' && e.node.id === id) as
        | { kind: 'group'; node: GroupNode }
        | undefined;
      if (!entry) return;
      entry.node.label = label;
      bump();
    },
    unregisterGroup(id) {
      const i = entries.findIndex((e) => e.kind === 'group' && e.node.id === id);
      if (i !== -1) {
        entries.splice(i, 1);
        bump();
      }
    },
    snapshot() {
      return entries.map((e): SelectOptionOrGroup<RegisteredSelectOption> =>
        e.kind === 'option' ? e.node.data : ({ label: e.node.label, options: e.node.optionCollector.snapshot() } as SelectOptionGroup<RegisteredSelectOption>),
      );
    },
  };
}

export const RootSelectOptionsContext = new Context<RootOptionCollector | undefined>();
export const GroupSelectOptionsContext = new Context<OptionCollector | undefined>();
