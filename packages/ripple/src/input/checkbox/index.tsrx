import { track, untrack, effect } from 'ripple';
import { CheckboxFoundation, type CheckboxState } from '@lotus/foundation/input/checkbox';
import { IconTick, IconMinus } from '@lotus/icons';
import { CheckboxContext } from './checkbox-context.js';

export interface CheckboxProps {
    children?: any;
    checked?: boolean;
    defaultChecked?: boolean;
    disabled?: boolean;
    indeterminate?: boolean;
    extra?: any;
    value?: string | number;
    onChange?: (checked: boolean) => void;
    'aria-label'?: string;
    style?: Record<string, any>;
    class?: string;
}

export function Checkbox(&{
    children,
    checked,
    defaultChecked = false,
    disabled = false,
    indeterminate = false,
    extra,
    value,
    onChange,
    'aria-label': ariaLabel,
    style,
    class: className,
}: CheckboxProps) @{
    const contextTracked = CheckboxContext.get();

    // Group 内使用时，选中态与 disabled 都由 Context 接管，自身 props 被忽略
    // （对齐 Semi："在 Group 中使用时无效"）；单独使用时才走自身 state。
    let &[inGroup] = track(() => contextTracked != null);
    let &[groupChecked] = track(() => value !== undefined && (contextTracked?.value.value.includes(value) ?? false));
    let &[groupDisabled] = track(() => contextTracked?.value.disabled ?? false);
    // type 只能通过 CheckboxGroup 设置（对齐 Semi），单独使用的 Checkbox 恒为 default。
    let &[groupType] = track(() => contextTracked?.value.type ?? 'default');
    let &[isCardType] = track(() => groupType !== 'default');
    let &[isPureCardType] = track(() => groupType === 'pureCard');

    // track() 而非普通 const——见 input/index.tsrx 同名注释，受控身份要能随
    // checked 的 undefined↔有值 变化重新判定，否则外部表单 reset 无法清空展示值。
    let &[isControlled] = track<boolean>(() => inGroup || checked !== undefined);
    let &[state] = track<CheckboxState>({
        checked: isControlled ? !!checked : defaultChecked,
        disabled,
    });

    const foundation = new CheckboxFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<CheckboxState>) => { state = { ...state, ...patch }; },
    });

    // 一旦组件经历过"非受控切换 state.checked → 被外部 checked 变为受控 →
    // 又变回 undefined"，如果不同步，切回非受控展示时 state.checked 会残留
    // 陈旧值。只针对 checked prop 本身（不涉及 inGroup——Group 内选中态完全
    // 由 Context 接管，displayChecked 在 inGroup 时不读 state.checked）。
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

    const handleClick = () => {
        if (inGroup) {
            if (effectiveDisabled || value === undefined) return;
            const ctx = untrack(() => contextTracked);
            ctx?.value.onItemToggle(value);
            return;
        }
        foundation.handleToggle(isControlled, onChange);
    };

    let &[classes] = track<string>(() =>
        [
            'lotus-checkbox',
            displayChecked ? 'lotus-checkbox-checked' : '',
            indeterminate ? 'lotus-checkbox-indeterminate' : '',
            effectiveDisabled ? 'lotus-checkbox-disabled' : '',
            isCardType ? 'lotus-checkbox-cardType' : '',
            isCardType && displayChecked ? 'lotus-checkbox-cardType-checked' : '',
            isCardType && effectiveDisabled ? 'lotus-checkbox-cardType-disabled' : '',
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
                type="checkbox"
                class="lotus-checkbox-native"
                checked={displayChecked}
                disabled={effectiveDisabled}
                aria-label={ariaLabel}
            />
            <span class={['lotus-checkbox-box', isPureCardType ? 'lotus-checkbox-box-pureCardType' : ''].filter(Boolean).join(' ')}>
                @if (indeterminate) {
                    <IconMinus />
                } @else {
                    @if (displayChecked) {
                        <IconTick />
                    }
                }
            </span>
            @if (children != null || extra != null) {
                <span class="lotus-checkbox-content">
                    @if (children != null) {
                        <span class="lotus-checkbox-label">{children}</span>
                    }
                    @if (extra != null) {
                        <span class={['lotus-checkbox-extra', isCardType && children == null ? 'lotus-checkbox-extra-noChildren' : ''].filter(Boolean).join(' ')}>{extra}</span>
                    }
                </span>
            }
        </label>

        <style>
            .lotus-checkbox {
                position: relative;
                display: inline-flex;
                align-items: flex-start;
                gap: 8px;
                cursor: pointer;
                user-select: none;
            }

            .lotus-checkbox-native {
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

            .lotus-checkbox-box {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                flex-shrink: 0;
                width: 16px;
                height: 16px;
                margin-top: 2px;
                box-sizing: border-box;
                border: var(--lotus-border-width-control) solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-small);
                background: var(--lotus-color-bg-1);
                color: #ffffff;
                font-size: 12px;
                transition: background-color 0.2s ease, border-color 0.2s ease;
            }

            .lotus-checkbox:hover .lotus-checkbox-box {
                border-color: var(--lotus-color-primary);
            }

            .lotus-checkbox-checked .lotus-checkbox-box,
            .lotus-checkbox-indeterminate .lotus-checkbox-box {
                border-color: var(--lotus-color-primary);
                background: var(--lotus-color-primary);
            }

            .lotus-checkbox-disabled {
                cursor: not-allowed;
            }

            .lotus-checkbox-disabled .lotus-checkbox-box {
                border-color: var(--lotus-color-border);
                background: var(--lotus-color-disabled-bg);
                color: var(--lotus-color-disabled-text);
            }

            .lotus-checkbox-disabled.lotus-checkbox-checked .lotus-checkbox-box,
            .lotus-checkbox-disabled.lotus-checkbox-indeterminate .lotus-checkbox-box {
                background: var(--lotus-color-disabled-bg);
                border-color: var(--lotus-color-border);
                color: var(--lotus-color-text-3);
            }

            .lotus-checkbox-content {
                display: flex;
                flex-direction: column;
                gap: 2px;
            }

            .lotus-checkbox-label {
                font-size: var(--lotus-font-body-size);
                color: var(--lotus-color-text-0);
                line-height: 16px;
            }

            .lotus-checkbox-disabled .lotus-checkbox-label {
                color: var(--lotus-color-disabled-text);
            }

            .lotus-checkbox-extra {
                font-size: var(--lotus-font-label-size);
                color: var(--lotus-color-text-2);
            }

            /* ---- cardType / pureCardType：带背景边框的卡片样式（对齐 Semi） ---- */
            .lotus-checkbox-cardType {
                align-items: flex-start;
                box-sizing: border-box;
                border-radius: var(--lotus-border-radius-small);
                padding: var(--lotus-spacing-base-tight) var(--lotus-spacing-base);
                background: transparent;
                border: var(--lotus-border-width-control) solid transparent;
                transition: background-color 0.2s ease, border-color 0.2s ease;
            }

            .lotus-checkbox-cardType:hover:not(.lotus-checkbox-cardType-disabled) {
                background: var(--lotus-color-fill-0);
            }

            .lotus-checkbox-cardType:active:not(.lotus-checkbox-cardType-disabled) {
                background: var(--lotus-color-fill-1);
            }

            .lotus-checkbox-cardType-checked {
                background: var(--lotus-color-primary-light-default);
                border-color: var(--lotus-color-primary);
            }

            .lotus-checkbox-cardType-checked:hover {
                background: var(--lotus-color-primary-light-default);
                border-color: var(--lotus-color-primary-hover);
            }

            .lotus-checkbox-cardType-checked:active {
                background: var(--lotus-color-primary-light-default);
                border-color: var(--lotus-color-primary-active);
            }

            .lotus-checkbox-cardType-disabled {
                cursor: not-allowed;
            }

            .lotus-checkbox-cardType-disabled.lotus-checkbox-cardType-checked {
                background: var(--lotus-color-primary-light-default);
                border-color: var(--lotus-color-disabled-border);
            }

            .lotus-checkbox-cardType .lotus-checkbox-box {
                background: var(--lotus-color-bg-1);
            }

            /* pureCardType：checkbox 方框用 opacity+width 隐藏而非 display:none——
               a11y 键盘聚焦依赖 input 的 focus/blur 事件，display:none 会让原生
               input 完全退出可聚焦树，隐藏后仍要保留可聚焦能力（对齐 Semi 的既有
               实现取舍，见 checkbox.scss 对应注释）。 */
            .lotus-checkbox-box-pureCardType {
                opacity: 0;
                width: 0;
                margin-top: 0;
                border: none;
            }

            .lotus-checkbox-cardType .lotus-checkbox-content {
                flex: 1;
            }

            .lotus-checkbox-cardType .lotus-checkbox-label {
                font-weight: var(--lotus-font-weight-semibold);
            }

            .lotus-checkbox-extra-noChildren {
                margin-top: 0;
            }
        </style>
    </>
}
