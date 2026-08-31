import { track, untrack } from 'ripple';
import { RadioGroupFoundation, type RadioGroupState } from '@lotus/foundation/input/radio';
import { RadioContext, type RadioContextValue, type RadioGroupType, type RadioGroupButtonSize } from './radio-context.js';
import { Radio } from './index.tsrx';

export type { RadioGroupType, RadioGroupButtonSize };
export type RadioGroupDirection = 'horizontal' | 'vertical';

export interface RadioGroupOption {
    value: string | number;
    label?: any;
    disabled?: boolean;
    extra?: any;
}

export interface RadioGroupProps {
    children?: any;
    options?: RadioGroupOption[];
    value?: string | number;
    defaultValue?: string | number;
    disabled?: boolean;
    /** 排列方向，只对 type="default" 生效。 */
    direction?: RadioGroupDirection;
    name?: string;
    /** 样式类型：default（普通）/button（分段按钮式）/card（卡片）/pureCard（无圆点纯卡片）。 */
    type?: RadioGroupType;
    /** type="button" 时的尺寸。 */
    buttonSize?: RadioGroupButtonSize;
    onChange?: (value: string | number) => void;
    'aria-label'?: string;
    style?: Record<string, any>;
    class?: string;
}

export function RadioGroup(&{
    children,
    options = [],
    value,
    defaultValue,
    disabled = false,
    direction = 'horizontal',
    name,
    type = 'default',
    buttonSize = 'middle',
    onChange,
    'aria-label': ariaLabel,
    style,
    class: className,
}: RadioGroupProps) @{
    const isControlled = value !== undefined;
    let &[state] = track<RadioGroupState>({
        value: isControlled ? value : defaultValue,
    });

    const foundation = new RadioGroupFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<RadioGroupState>) => { state = { ...state, ...patch }; },
    });

    let &[displayValue] = track<string | number | undefined>(() => (isControlled ? value : state.value));

    const handleItemSelect = (itemValue: string | number) => {
        foundation.selectValue(itemValue, isControlled, onChange);
    };

    let &[, contextValue] = track<RadioContextValue>(() => ({
        value: displayValue,
        disabled,
        name,
        type,
        buttonSize,
        onItemSelect: handleItemSelect,
    }));
    RadioContext.set(contextValue);

    let &[classes] = track<string>(() =>
        [
            'lotus-radio-group',
            type === 'default' ? `lotus-radio-group-${direction}` : '',
            type === 'button' ? 'lotus-radio-group-buttonType' : '',
            (type === 'card' || type === 'pureCard') ? 'lotus-radio-group-cardType' : '',
            className ?? '',
        ]
            .filter(Boolean)
            .join(' '),
    );

    <>
        <div class={classes} style={style} role="list" aria-label={ariaLabel}>
            @if (children != null) {
                <>{children}</>
            } @else {
                @for (const option of options; key option.value) {
                    <Radio value={option.value} disabled={option.disabled} extra={option.extra} children={option.label ?? String(option.value)} />
                }
            }
        </div>

        <style>
            .lotus-radio-group {
                display: flex;
            }

            .lotus-radio-group-vertical {
                flex-direction: column;
                gap: 8px;
            }

            .lotus-radio-group-horizontal {
                flex-direction: row;
                flex-wrap: wrap;
                gap: 16px;
            }

            /* type="button"：分段按钮式，Group 整体一个圆角浅底外壳，选中项
               各自渲染实心背景高亮（对齐 Semi 的 buttonRadioGroup 外壳 +
               buttonRadio 内部选中态设计，简化为单层背景而非逐项独立边框）。 */
            .lotus-radio-group-buttonType {
                display: inline-flex;
                flex-direction: row;
                gap: 2px;
                padding: 2px;
                background: var(--lotus-color-fill-0);
                border-radius: var(--lotus-border-radius-small);
            }

            /* type="card"/"pureCard"：默认纵向排列的卡片列表。 */
            .lotus-radio-group-cardType {
                flex-direction: column;
                gap: 8px;
            }
        </style>
    </>
}
