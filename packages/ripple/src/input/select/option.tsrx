import { effect, untrack } from 'ripple';
import { RootSelectOptionsContext, GroupSelectOptionsContext } from './select-option-context.js';
import type { SelectValue } from '@lotus/foundation/input/select';

/**
 * 组合式候选项声明（对齐 Semi `<Select.Option>`），与配置式 `optionList` prop
 * 并存（`optionList` 非空时优先生效）。不渲染任何可见 DOM：只把自身字段注册进
 * 最近的收集器（`<Select.OptGroup>` 内则注册进组收集器，否则注册进 Select
 * 根收集器），实际渲染由 Select 内部统一负责（含 activeIndex/键盘/虚拟化）。
 */
export interface SelectOptionProps {
    value: SelectValue;
    label?: any;
    disabled?: boolean;
}

export function Option(&{ value, label, disabled }: SelectOptionProps) @{
    const groupCtx = GroupSelectOptionsContext.get();
    const rootCtx = RootSelectOptionsContext.get();
    const ctx = groupCtx ?? rootCtx;

    const optId = ctx ? untrack(() => ctx.register({ value, label, disabled })) : -1;

    effect(() => {
        if (optId === -1 || !ctx) return;
        ctx.update(optId, { value, label, disabled });
    });

    effect(() => {
        return () => {
            if (optId !== -1 && ctx) ctx.unregister(optId);
        };
    });

    <></>
}
