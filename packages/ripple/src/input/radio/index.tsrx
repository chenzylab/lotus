import { track, untrack, effect } from 'ripple';
import { RadioFoundation, type RadioState } from '@lotus/foundation/input/radio';
import { RadioContext } from './radio-context.js';

export type RadioMode = 'default' | 'advanced';

export interface RadioApi {
    /** 命令式聚焦原生 radio（对齐 Semi 的 ref.current.focus()；与 Input 的
     * getInputApi 同一模式）。`preventScroll` 透传给原生 focus() 的同名选项。 */
    focus: (options?: { preventScroll?: boolean }) => void;
    /** 命令式移出焦点，同上。 */
    blur: () => void;
}

export interface RadioProps {
    children?: any;
    checked?: boolean;
    defaultChecked?: boolean;
    disabled?: boolean;
    extra?: any;
    /** extra 副文本的 id，配合 aria-describedby 建立语义关联；不传则自动生成。 */
    extraId?: string;
    /** 包裹内容（children + extra）容器的类名。 */
    addonClassName?: string;
    /** 包裹内容容器的内联样式。 */
    addonStyle?: Record<string, any>;
    /** addon 容器的 id，配合 aria-labelledby 建立语义关联；不传则自动生成。 */
    addonId?: string;
    autoFocus?: boolean;
    mode?: RadioMode;
    value?: string | number;
    name?: string;
    getRadioApi?: (api: RadioApi) => void;
    onChange?: (checked: boolean) => void;
    onMouseEnter?: (event: MouseEvent) => void;
    onMouseLeave?: (event: MouseEvent) => void;
    'aria-label'?: string;
    style?: Record<string, any>;
    class?: string;
}

let radioIdCounter = 0;

export function Radio(&{
    children,
    checked,
    defaultChecked = false,
    disabled = false,
    extra,
    extraId,
    addonClassName,
    addonStyle,
    addonId,
    autoFocus = false,
    mode = 'default',
    value,
    name,
    getRadioApi,
    onChange,
    onMouseEnter,
    onMouseLeave,
    'aria-label': ariaLabel,
    style,
    class: className,
}: RadioProps) @{
    const contextTracked = RadioContext.get();
    let radioEl: HTMLInputElement | null = null;
    const resolvedExtraId = extraId ?? (extra != null ? `lotus-radio-extra-${++radioIdCounter}` : undefined);
    const resolvedAddonId = addonId ?? ((children != null || extra != null) ? `lotus-radio-addon-${++radioIdCounter}` : undefined);

    getRadioApi?.({
        focus: (options) => radioEl?.focus(options),
        blur: () => radioEl?.blur(),
    });

    // Group 内使用时，选中态与 disabled 都由 Context 接管，自身 props 被忽略
    // （对齐 Semi："在 Group 中使用时无效"，同 Checkbox 的处理方式）。
    let &[inGroup] = track(() => contextTracked != null);
    let &[groupChecked] = track(() => value !== undefined && contextTracked?.value.value === value);
    let &[groupDisabled] = track(() => contextTracked?.value.disabled ?? false);
    let &[groupName] = track(() => contextTracked?.value.name);
    // type/buttonSize 只能通过 RadioGroup 设置（对齐 Semi），单独使用的 Radio 恒为 default。
    let &[groupType] = track(() => contextTracked?.value.type ?? 'default');
    let &[groupButtonSize] = track(() => contextTracked?.value.buttonSize ?? 'middle');
    let &[isButtonType] = track(() => groupType === 'button');
    let &[isCardType] = track(() => groupType === 'card' || groupType === 'pureCard');
    let &[isPureCardType] = track(() => groupType === 'pureCard');

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
            isButtonType ? 'lotus-radio-buttonType' : '',
            isButtonType ? `lotus-radio-buttonType-${groupButtonSize}` : '',
            isCardType ? 'lotus-radio-cardType' : '',
            isCardType && displayChecked ? 'lotus-radio-cardType-checked' : '',
            isCardType && effectiveDisabled ? 'lotus-radio-cardType-disabled' : '',
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
            onMouseEnter={(event: MouseEvent) => onMouseEnter?.(event)}
            onMouseLeave={(event: MouseEvent) => onMouseLeave?.(event)}
        >
            <input
                ref={(node: HTMLInputElement) => { radioEl = node; }}
                type="radio"
                class="lotus-radio-native"
                checked={displayChecked}
                disabled={effectiveDisabled}
                name={effectiveName}
                autofocus={autoFocus}
                aria-label={ariaLabel}
                aria-labelledby={resolvedAddonId}
                aria-describedby={resolvedExtraId}
            />
            @if (!isButtonType) {
                <span class={['lotus-radio-dot', isPureCardType ? 'lotus-radio-dot-pureCardType' : ''].filter(Boolean).join(' ')} />
            }
            @if (children != null || extra != null) {
                <span id={resolvedAddonId} class={['lotus-radio-content', addonClassName ?? ''].filter(Boolean).join(' ')} style={addonStyle}>
                    @if (children != null) {
                        <span class="lotus-radio-label">{children}</span>
                    }
                    @if (extra != null) {
                        <span id={resolvedExtraId} class={['lotus-radio-extra', isCardType && children == null ? 'lotus-radio-extra-noChildren' : ''].filter(Boolean).join(' ')}>{extra}</span>
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

            /* ---- buttonType：分段按钮式，选中项渲染实心背景高亮（对齐 Semi） ---- */
            .lotus-radio-buttonType {
                gap: 0;
                align-items: center;
                justify-content: center;
                padding: 0 var(--lotus-spacing-base);
                border-radius: var(--lotus-border-radius-small);
                font-weight: var(--lotus-font-weight-semibold);
                color: var(--lotus-color-text-1);
                transition: background-color 0.2s ease, color 0.2s ease;
            }

            .lotus-radio-buttonType-small { height: var(--lotus-height-control-small); font-size: var(--lotus-font-label-size); }
            .lotus-radio-buttonType-middle { height: var(--lotus-height-control-default); font-size: var(--lotus-font-body-size); }
            .lotus-radio-buttonType-large { height: var(--lotus-height-control-large); font-size: var(--lotus-font-body-size); }

            .lotus-radio-buttonType:hover:not(.lotus-radio-disabled) {
                background: var(--lotus-color-fill-1);
            }

            .lotus-radio-buttonType.lotus-radio-checked {
                background: var(--lotus-color-bg-1);
                color: var(--lotus-color-primary);
                box-shadow: var(--lotus-shadow-elevated);
            }

            .lotus-radio-buttonType.lotus-radio-disabled {
                color: var(--lotus-color-disabled-text);
                cursor: not-allowed;
            }

            /* ---- cardType / pureCardType：带背景边框的卡片样式（对齐 Semi，与 Checkbox 同一设计） ---- */
            .lotus-radio-cardType {
                align-items: flex-start;
                box-sizing: border-box;
                border-radius: var(--lotus-border-radius-small);
                padding: var(--lotus-spacing-base-tight) var(--lotus-spacing-base);
                background: transparent;
                border: var(--lotus-border-width-control) solid transparent;
                transition: background-color 0.2s ease, border-color 0.2s ease;
            }

            .lotus-radio-cardType:hover:not(.lotus-radio-cardType-disabled) {
                background: var(--lotus-color-fill-0);
            }

            .lotus-radio-cardType:active:not(.lotus-radio-cardType-disabled) {
                background: var(--lotus-color-fill-1);
            }

            .lotus-radio-cardType-checked {
                background: var(--lotus-color-primary-light-default);
                border-color: var(--lotus-color-primary);
            }

            .lotus-radio-cardType-checked:hover {
                background: var(--lotus-color-primary-light-default);
                border-color: var(--lotus-color-primary-hover);
            }

            .lotus-radio-cardType-checked:active {
                background: var(--lotus-color-primary-light-default);
                border-color: var(--lotus-color-primary-active);
            }

            .lotus-radio-cardType-disabled {
                cursor: not-allowed;
            }

            .lotus-radio-cardType-disabled.lotus-radio-cardType-checked {
                background: var(--lotus-color-primary-light-default);
                border-color: var(--lotus-color-disabled-border);
            }

            .lotus-radio-cardType .lotus-radio-dot {
                background: var(--lotus-color-bg-1);
            }

            /* pureCardType：radio 圆点用 opacity+width 隐藏而非 display:none——
               a11y 键盘聚焦依赖 input 的 focus/blur 事件，与 Checkbox 的
               pureCardType 同一取舍。 */
            .lotus-radio-dot-pureCardType {
                opacity: 0;
                width: 0;
                margin-top: 0;
                border: none;
            }

            .lotus-radio-cardType .lotus-radio-content {
                flex: 1;
            }

            .lotus-radio-cardType .lotus-radio-label {
                font-weight: var(--lotus-font-weight-semibold);
            }

            .lotus-radio-extra-noChildren {
                margin-top: 0;
            }
        </style>
    </>
}
