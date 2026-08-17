import { Form, Field, Input, Button, Space } from '@lotus/ripple';
import type { FieldRenderProps, FormApi } from '@lotus/ripple';

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

export function FormApiDemo() {
    let formApiRef: FormApi | undefined;

    return (
        <Form initValues={{ username: '' }} getFormApi={(api) => { formApiRef = api; }}>
            <Field field="username" label="用户名" Comp={FormTextInput} />
            <Space>
                <Button onClick={() => formApiRef?.setValue('username', '预填用户名')}>外部设置值</Button>
                <Button onClick={() => formApiRef?.reset()}>外部重置</Button>
            </Space>
        </Form>
    );
}
