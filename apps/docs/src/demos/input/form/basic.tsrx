import { Form, Field, Input } from '@lotus/ripple';
import type { FieldRenderProps } from '@lotus/ripple';

function FormTextInput(&{ value, disabled, onChange, onBlur, 'aria-label': ariaLabel }: FieldRenderProps) {
    return (
        <Input
            value={value ?? ''}
            disabled={disabled}
            onChange={(v) => onChange(v)}
            onBlur={onBlur}
            aria-label={ariaLabel}
            placeholder="请输入用户名"
        />
    );
}

export function FormBasicDemo() {
    return (
        <Form initValues={{ username: '' }} onValueChange={(values) => console.log('form value changed', values)}>
            <Field field="username" label="用户名" Comp={FormTextInput} />
        </Form>
    );
}
