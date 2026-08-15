import { track } from 'ripple';
import { SwitchFoundation, type SwitchState } from '@lotus/foundation/input/switch';

export interface SwitchProps {
    checked?: boolean;
    defaultChecked?: boolean;
    disabled?: boolean;
    loading?: boolean;
    size?: 'large' | 'default' | 'small';
    checkedText?: any;
    uncheckedText?: any;
    onChange?: (checked: boolean) => void;
    'aria-label'?: string;
    style?: Record<string, any>;
    class?: string;
}

export function Switch({
    checked,
    defaultChecked = false,
    disabled = false,
    loading = false,
    size = 'default',
    checkedText,
    uncheckedText,
    onChange,
    'aria-label': ariaLabel,
    style,
    class: className,
}: SwitchProps) @{
    const isControlled = checked !== undefined;
    let &[state] = track<SwitchState>({
        checked: isControlled ? !!checked : defaultChecked,
        disabled,
        loading,
    });

    const foundation = new SwitchFoundation({
        getState: () => state,
        setState: (patch: Partial<SwitchState>) => { state = { ...state, ...patch }; },
    });

    // 受控模式下，视觉状态直接跟随外部传入的 checked，不依赖内部 state.checked
    // （Foundation 受控分支不改写 state，见 SwitchFoundation.handleToggle 注释）。
    let &[displayChecked] = track<boolean>(() => (isControlled ? !!checked : state.checked));

    // classes 必须是派生 track，不能用普通 const 一次性拼接——普通 const 只在组件
    // setup 阶段计算一次，displayChecked 后续变化不会让它重新求值，视觉会与实际状态
    // 脱节（真机点击实测发现：onChange 正确触发但按钮外观不跟着切换）。同类踩坑详见
    // specs/cross-cutting/foundation-adapter-pattern.md 踩坑 #7。
    let &[classes] = track<string>(() =>
        [
            'lotus-switch',
            `lotus-switch-${size}`,
            displayChecked ? 'lotus-switch-checked' : '',
            (disabled || loading) ? 'lotus-switch-disabled' : '',
            className ?? '',
        ]
            .filter(Boolean)
            .join(' '),
    );

    <>
        <button
            type="button"
            role="switch"
            aria-checked={displayChecked}
            aria-label={ariaLabel}
            disabled={disabled || loading}
            class={classes}
            style={style}
            onClick={() => foundation.handleToggle(isControlled, onChange)}
        >
            <span class="lotus-switch-knob">
                @if (loading) {
                    <span class="lotus-switch-spinner" />
                }
            </span>
            @if (checkedText || uncheckedText) {
                <span class="lotus-switch-text">
                    {displayChecked ? checkedText : uncheckedText}
                </span>
            }
        </button>

        <style>
            .lotus-switch {
                position: relative;
                display: inline-flex;
                align-items: center;
                box-sizing: border-box;
                border: none;
                border-radius: var(--lotus-border-radius-full);
                background: var(--lotus-color-fill-1);
                cursor: pointer;
                padding: 2px;
                transition: background-color 0.2s ease;
            }

            .lotus-switch-default {
                width: 40px;
                height: 24px;
            }

            .lotus-switch-large {
                width: 48px;
                height: 28px;
            }

            .lotus-switch-small {
                width: 28px;
                height: 16px;
            }

            .lotus-switch-checked {
                background: var(--lotus-color-primary);
            }

            .lotus-switch-checked:hover:not(:disabled) {
                background: var(--lotus-color-primary-hover);
            }

            .lotus-switch:not(.lotus-switch-checked):hover:not(:disabled) {
                background: var(--lotus-color-fill-2);
            }

            .lotus-switch-knob {
                display: flex;
                align-items: center;
                justify-content: center;
                width: 20px;
                height: 20px;
                border-radius: var(--lotus-border-radius-circle);
                background: #ffffff;
                box-shadow: 0 1px 2px rgba(0, 0, 0, 0.15);
                transition: transform 0.2s ease;
            }

            .lotus-switch-small .lotus-switch-knob {
                width: 12px;
                height: 12px;
            }

            .lotus-switch-checked .lotus-switch-knob {
                transform: translateX(16px);
            }

            .lotus-switch-large.lotus-switch-checked .lotus-switch-knob {
                transform: translateX(20px);
            }

            .lotus-switch-small.lotus-switch-checked .lotus-switch-knob {
                transform: translateX(12px);
            }

            .lotus-switch-disabled {
                cursor: not-allowed;
                background: var(--lotus-color-disabled-bg);
            }

            .lotus-switch-disabled.lotus-switch-checked {
                background: var(--lotus-color-primary-disabled);
            }

            .lotus-switch-spinner {
                width: 8px;
                height: 8px;
                border-radius: var(--lotus-border-radius-circle);
                border: 1.5px solid var(--lotus-color-fill-2);
                border-top-color: var(--lotus-color-primary);
                animation: lotus-switch-spin 0.6s linear infinite;
            }

            @keyframes lotus-switch-spin {
                to {
                    transform: rotate(360deg);
                }
            }

            .lotus-switch-text {
                position: absolute;
                font-size: var(--lotus-font-label-size);
                color: #ffffff;
                pointer-events: none;
            }
        </style>
    </>
}
