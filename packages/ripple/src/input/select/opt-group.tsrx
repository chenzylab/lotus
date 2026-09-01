import { effect, untrack } from 'ripple';
import { RootSelectOptionsContext, GroupSelectOptionsContext, type OptionCollector } from './select-option-context.js';

/**
 * 组合式分组声明（对齐 Semi `<Select.OptGroup>`）。不渲染任何可见 DOM：向
 * Select 根收集器注册自身、拿到「组内收集器」并下发给自己的 `<Select.Option>`
 * children——Semi 不支持分组嵌套分组，故本组件不再向下提供根收集器，只提供
 * 组收集器。
 */
export interface SelectOptGroupProps {
    label: any;
    children?: any;
}

export function OptGroup(&{ label, children }: SelectOptGroupProps) @{
    const rootCtx = RootSelectOptionsContext.get();
    const reg = rootCtx ? untrack(() => rootCtx.registerGroup(label)) : undefined;
    if (reg) GroupSelectOptionsContext.set(reg.collector as OptionCollector);

    effect(() => {
        if (!reg || !rootCtx) return;
        rootCtx.updateGroupLabel(reg.id, label);
    });

    effect(() => {
        return () => {
            if (reg && rootCtx) rootCtx.unregisterGroup(reg.id);
        };
    });

    <>{children}</>
}
