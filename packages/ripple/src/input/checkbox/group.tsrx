import { track, untrack } from 'ripple';
import { CheckboxGroupFoundation, type CheckboxGroupState } from '@lotus/foundation/input/checkbox';
import { CheckboxContext, type CheckboxContextValue, type CheckboxGroupType } from './checkbox-context.js';
import { Checkbox } from './index.tsrx';

export type { CheckboxGroupType };
export type CheckboxGroupDirection = 'horizontal' | 'vertical';

export interface CheckboxGroupOption {
    value: string | number;
    label?: any;
    disabled?: boolean;
    extra?: any;
}

export interface CheckboxGroupProps {
    children?: any;
    options?: CheckboxGroupOption[];
    value?: Array<string | number>;
    defaultValue?: Array<string | number>;
    disabled?: boolean;
    direction?: CheckboxGroupDirection;
    /** 组内所有 Checkbox 的样式类型：`default` 默认样式；`card` 带背景边框的卡片样式；
     * `pureCard` 卡片样式且不显示 checkbox 方框图标（对齐 Semi）。 */
    type?: CheckboxGroupType;
    name?: string;
    onChange?: (value: Array<string | number>) => void;
    'aria-label'?: string;
    style?: Record<string, any>;
    class?: string;
}

export function CheckboxGroup(&{
    children,
    options = [],
    value,
    defaultValue = [],
    disabled = false,
    direction = 'vertical',
    type = 'default',
    onChange,
    'aria-label': ariaLabel,
    style,
    class: className,
}: CheckboxGroupProps) @{
    const isControlled = value !== undefined;
    let &[state] = track<CheckboxGroupState>({
        value: isControlled ? (value ?? []) : defaultValue,
    });

    // 受控模式下 getState 必须返回"当前外部值"而不是内部 state 快照——内部 state 只在
    // 非受控模式下才会被 setState 同步，受控时它永远停留在组件初始化那一刻的旧值。
    // toggleValue 需要基于"当前真实的完整集合"做增删运算（例如判断 itemValue 是否已
    // 存在），如果读到过时快照，选中多个项后再点击会把之前已选中的项错误地丢弃
    // （真机复现：CheckboxGroup 受控模式下先勾选 B，再勾选/取消 A，B 的选中状态会
    // 被意外清空）。
    const foundation = new CheckboxGroupFoundation({
        getState: () => ({ value: isControlled ? (value ?? []) : untrack(() => state.value) }),
        setState: (patch: Partial<CheckboxGroupState>) => { state = { ...state, ...patch }; },
    });

    let &[displayValue] = track<Array<string | number>>(() => (isControlled ? (value ?? []) : state.value));

    const handleItemToggle = (itemValue: string | number) => {
        foundation.toggleValue(itemValue, isControlled, onChange);
    };

    let &[, contextValue] = track<CheckboxContextValue>(() => ({
        value: displayValue,
        disabled,
        type,
        onItemToggle: handleItemToggle,
    }));
    CheckboxContext.set(contextValue);

    let &[classes] = track<string>(() =>
        [
            'lotus-checkbox-group',
            `lotus-checkbox-group-${direction}`,
            type !== 'default' ? `lotus-checkbox-group-${direction}-cardType` : '',
            type === 'pureCard' ? 'lotus-checkbox-group-pureCardType' : '',
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
                    <Checkbox value={option.value} disabled={option.disabled} children={option.label ?? String(option.value)} />
                }
            }
        </div>

        <style>
            .lotus-checkbox-group {
                display: flex;
            }

            .lotus-checkbox-group-vertical {
                flex-direction: column;
                gap: 8px;
            }

            .lotus-checkbox-group-horizontal {
                flex-direction: row;
                flex-wrap: wrap;
                gap: 16px;
            }

            .lotus-checkbox-group-vertical-cardType {
                gap: var(--lotus-spacing-tight);
            }

            .lotus-checkbox-group-pureCardType .lotus-checkbox {
                column-gap: 0;
            }
        </style>
    </>
}
