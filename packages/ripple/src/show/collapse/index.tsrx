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

