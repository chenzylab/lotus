import { track, untrack } from 'ripple';
import { RadioGroupFoundation, type RadioGroupState } from '@lotus/foundation/input/radio';
import { RadioContext, type RadioContextValue } from './radio-context.js';
import { Radio } from './index.tsrx';

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
    direction?: RadioGroupDirection;
    name?: string;
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
        onItemSelect: handleItemSelect,
    }));
    RadioContext.set(contextValue);

    let &[classes] = track<string>(() =>
        [
            'lotus-radio-group',
            `lotus-radio-group-${direction}`,
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
        </style>
    </>
}
