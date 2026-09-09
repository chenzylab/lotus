import { track, effect, untrack } from 'ripple';
import { CollapseFoundation, initActiveKeys, type CollapseState } from '@lotus/foundation/show/collapse';
import { CollapseContext, type CollapseContextValue } from './collapse-context.js';

export interface CollapseProps {
    children?: any;
    activeKey?: string | string[];
    defaultActiveKey?: string | string[];
    accordion?: boolean;
    clickHeaderToExpand?: boolean;
    expandIconPosition?: 'left' | 'right';
    expandIcon?: any;
    collapseIcon?: any;
    /** 收起态是否保留 Panel 内容的 DOM（不销毁重建），透传给内部 Collapsible。 */
    keepDOM?: boolean;
    /** 展开/收起是否有动画过渡，false 时立即切换。 */
    motion?: boolean;
    /** 内容首次展开前不渲染，展开一次后即使收起也保留 DOM（需要 keepDOM 才有意义）。 */
    lazyRender?: boolean;
    onChange?: (activeKey: string[], event: MouseEvent) => void;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

export function Collapse(&{
    children,
    activeKey: activeKeyProp,
    defaultActiveKey,
    accordion = false,
    clickHeaderToExpand = true,
    expandIconPosition = 'right',
    expandIcon,
    collapseIcon,
    keepDOM = false,
    motion = true,
    lazyRender = false,
    onChange,
    style,
    class: className,
    'aria-label': ariaLabel,
}: CollapseProps) @{
    const isControlled = activeKeyProp !== undefined;

    let &[state] = track<CollapseState>({
        activeKeys: initActiveKeys(isControlled ? activeKeyProp : defaultActiveKey, accordion),
    });

    const foundation = new CollapseFoundation({
        getState: () => untrack(() => state),
        setState: (patch) => { state = { ...untrack(() => state), ...patch }; },
    });

    effect(() => {
        if (!isControlled) return;
        const next = initActiveKeys(activeKeyProp, accordion);
        const current = untrack(() => state);
        const same = current.activeKeys.size === next.size && [...next].every((k) => current.activeKeys.has(k));
        if (same) return;
        state = { ...current, activeKeys: next };
    });

    function handleToggle(key: string, event: MouseEvent) {
        const next = foundation.handleToggle(key, accordion);
        onChange?.([...next], event);
    }

    let &[classes] = track<string>(() => ['lotus-collapse', className ?? ''].filter(Boolean).join(' '));

    let &[, contextTracked] = track<CollapseContextValue>(() => ({
        activeKeys: state.activeKeys,
        clickHeaderToExpand,
        expandIconPosition,
        onToggle: handleToggle,
        motion,
        keepDOM,
        lazyRender,
        expandIcon,
        collapseIcon,
    }));
    CollapseContext.set(contextTracked);

    <>
        <div class={classes} style={style} aria-label={ariaLabel}>
            {children}
        </div>

        <style>
            .lotus-collapse {
                display: flex;
                flex-direction: column;
            }
        </style>
    </>
}

