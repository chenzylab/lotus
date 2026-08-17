import { track, untrack, effect } from 'ripple';
import { RadioFoundation, type RadioState } from '@lotus/foundation/input/radio';
import { RadioContext } from './radio-context.js';

export type RadioMode = 'default' | 'advanced';

export interface RadioProps {
    children?: any;
    checked?: boolean;
    defaultChecked?: boolean;
    disabled?: boolean;
    extra?: any;
    mode?: RadioMode;
    value?: string | number;
    name?: string;
    onChange?: (checked: boolean) => void;
    'aria-label'?: string;
    style?: Record<string, any>;
    class?: string;
}

export function Radio(&{
    children,
    checked,
    defaultChecked = false,
    disabled = false,
    extra,
    mode = 'default',
    value,
    name,
    onChange,
    'aria-label': ariaLabel,
    style,
    class: className,
}: RadioProps) @{
    const contextTracked = RadioContext.get();

    // Group 内使用时，选中态与 disabled 都由 Context 接管，自身 props 被忽略
    // （对齐 Semi："在 Group 中使用时无效"，同 Checkbox 的处理方式）。
    let &[inGroup] = track(() => contextTracked != null);
    let &[groupChecked] = track(() => value !== undefined && contextTracked?.value.value === value);
    let &[groupDisabled] = track(() => contextTracked?.value.disabled ?? false);
    let &[groupName] = track(() => contextTracked?.value.name);

    // track() 而非普通 const——见 input/index.tsrx 同名注释，受控身份要能随
    // checked 的 undefined↔有值 变化重新判定，否则外部表单 reset 无法清空展示值。
    let &[isControlled] = track<boolean>(() => inGroup || checked !== undefined);
    let &[state] = track<RadioState>({
        checked: isControlled ? !!checked : defaultChecked,
        disabled,
    });

    const foundation = new RadioFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<RadioState>) => { state = { ...state, ...patch }; },
    });

    // 一旦组件经历过"非受控切换 state.checked → 被外部 checked 变为受控 →
    // 又变回 undefined"，如果不同步，切回非受控展示时 state.checked 会残留
    // 陈旧值。只针对 checked prop 本身（不涉及 inGroup，理由同 Checkbox）。
    // 详见 input-number/index.tsrx 同名注释与
    // specs/cross-cutting/foundation-adapter-pattern.md。
    let &[hasBeenControlled] = track<boolean>(false);
    effect(() => {
        if (checked !== undefined) {
            hasBeenControlled = true;
            untrack(() => { state = { ...state, checked }; });
        } else if (untrack(() => hasBeenControlled)) {
            untrack(() => { state = { ...state, checked: false }; });
        }
    });

    let &[displayChecked] = track<boolean>(() => (inGroup ? groupChecked : isControlled ? !!checked : state.checked));
    let &[effectiveDisabled] = track<boolean>(() => inGroup ? groupDisabled || disabled : disabled);
    let &[effectiveName] = track<string | undefined>(() => inGroup ? groupName : name);

    const handleClick = () => {
        if (inGroup) {
            if (effectiveDisabled || value === undefined) return;
            const ctx = untrack(() => contextTracked);
            ctx?.value.onItemSelect(value);
            return;
        }
        foundation.handleToggle(isControlled, mode === 'advanced', onChange);
    };

    let &[classes] = track<string>(() =>
        [
            'lotus-radio',
            displayChecked ? 'lotus-radio-checked' : '',
            effectiveDisabled ? 'lotus-radio-disabled' : '',
            className ?? '',
        ]
            .filter(Boolean)
            .join(' '),
    );

    <>
        <label
            class={classes}
            style={style}
            role={inGroup ? 'listitem' : undefined}
            onClick={(event: MouseEvent) => { event.preventDefault(); handleClick(); }}
        >
            <input
                type="radio"
                class="lotus-radio-native"
                checked={displayChecked}
                disabled={effectiveDisabled}
                name={effectiveName}
                aria-label={ariaLabel}
            />
            <span class="lotus-radio-dot" />
            @if (children != null || extra != null) {
                <span class="lotus-radio-content">
                    @if (children != null) {
                        <span class="lotus-radio-label">{children}</span>
                    }
                    @if (extra != null) {
                        <span class="lotus-radio-extra">{extra}</span>
                    }
                </span>
            }
        </label>

        <style>
            .lotus-radio {
                position: relative;
                display: inline-flex;
                align-items: flex-start;
                gap: 8px;
                cursor: pointer;
                user-select: none;
            }

            .lotus-radio-native {
                position: absolute;
                width: 1px;
                height: 1px;
                margin: -1px;
                overflow: hidden;
                clip: rect(0, 0, 0, 0);
                white-space: nowrap;
                border: 0;
                padding: 0;
                pointer-events: none;
            }

            .lotus-radio-dot {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                flex-shrink: 0;
                width: 16px;
                height: 16px;
                margin-top: 2px;
                box-sizing: border-box;
                border: var(--lotus-border-width-control) solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-circle);
                background: var(--lotus-color-bg-1);
                transition: border-color 0.2s ease;
            }

            .lotus-radio-dot::after {
                content: '';
                width: 8px;
                height: 8px;
                border-radius: var(--lotus-border-radius-circle);
                background: var(--lotus-color-primary);
                transform: scale(0);
                transition: transform 0.15s ease;
            }

            .lotus-radio:hover .lotus-radio-dot {
                border-color: var(--lotus-color-primary);
            }

            .lotus-radio-checked .lotus-radio-dot {
                border-color: var(--lotus-color-primary);
            }

            .lotus-radio-checked .lotus-radio-dot::after {
                transform: scale(1);
            }

            .lotus-radio-disabled {
                cursor: not-allowed;
            }

            .lotus-radio-disabled .lotus-radio-dot {
                border-color: var(--lotus-color-border);
                background: var(--lotus-color-disabled-bg);
            }

            .lotus-radio-disabled .lotus-radio-dot::after {
                background: var(--lotus-color-text-3);
            }

            .lotus-radio-content {
                display: flex;
                flex-direction: column;
                gap: 2px;
            }

            .lotus-radio-label {
                font-size: var(--lotus-font-body-size);
                color: var(--lotus-color-text-0);
                line-height: 16px;
            }

            .lotus-radio-disabled .lotus-radio-label {
                color: var(--lotus-color-disabled-text);
            }

            .lotus-radio-extra {
                font-size: var(--lotus-font-label-size);
                color: var(--lotus-color-text-2);
            }
        </style>
    </>
}
