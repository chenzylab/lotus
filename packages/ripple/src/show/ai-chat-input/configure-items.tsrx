import { Select, type SelectOptionData } from '../../input/select/index.tsrx';
import type { SelectValue } from '@lotus/foundation/input/select';
import { Button, type ButtonProps } from '../../basic/button/index.tsrx';
import { RadioGroup, type RadioGroupOption } from '../../input/radio/group.tsrx';

/**
 * Configure.Select/Button/RadioButton：footer 配置区的受控字段封装。Semi 用
 * React HOC（`getConfigureItem`）把 `field` 映射进 Context 里的 `configureValue`；
 * Ripple 没有 HOC 概念，改用"显式接收 field 当前值 + onChange 回调"的薄封装
 * ——调用方（主组件）负责把 `foundation.updateConfigureField(field, value)`
 * 接到这里的 `onChange`，语义等价但不引入额外抽象层。
 */

export interface ConfigureSelectProps {
    optionList?: SelectOptionData[];
    value?: SelectValue | SelectValue[];
    onChange?: (value: SelectValue | SelectValue[] | undefined) => void;
    placeholder?: string;
    class?: string;
    style?: Record<string, any>;
}

export function ConfigureSelect(&{ optionList, value, onChange, placeholder, class: className, style }: ConfigureSelectProps) @{
    <Select
        optionList={optionList}
        value={value}
        onChange={onChange}
        placeholder={placeholder}
        size="small"
        class={['lotus-ai-input-configure-select', className ?? ''].filter(Boolean).join(' ')}
        style={style}
    />
}

export interface ConfigureButtonProps extends Omit<ButtonProps, 'onClick'> {
    field?: string;
    onClick?: () => void;
}

export function ConfigureButton(&{ children, theme = 'outline', size = 'small', icon, onClick, class: className, style }: ConfigureButtonProps) @{
    <Button theme={theme} size={size} icon={icon} onClick={onClick} class={['lotus-ai-input-configure-button', className ?? ''].filter(Boolean).join(' ')} style={style}>
        {children}
    </Button>
}

export interface ConfigureRadioButtonProps {
    options?: RadioGroupOption[];
    value?: string | number;
    onChange?: (value: string | number) => void;
    class?: string;
    style?: Record<string, any>;
}

export function ConfigureRadioButton(&{ options, value, onChange, class: className, style }: ConfigureRadioButtonProps) @{
    <RadioGroup options={options} value={value} onChange={onChange} class={['lotus-ai-input-configure-radio', className ?? ''].filter(Boolean).join(' ')} style={style} />
}
