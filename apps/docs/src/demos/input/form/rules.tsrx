import { Form, Field, Input, InputNumber, Button, Space } from '@lotus/ripple';
import type { FieldRenderProps } from '@lotus/ripple';

function FormUsernameInput(&{ value, disabled, onChange, onBlur, 'aria-label': ariaLabel }: FieldRenderProps) {
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

function FormAgeInput(&{ value, disabled, onChange, onBlur, 'aria-label': ariaLabel }: FieldRenderProps) {
    return (
        <InputNumber
            value={value}
            disabled={disabled}
            onChange={(v) => onChange(v)}
            onBlur={onBlur}
            aria-label={ariaLabel}
            placeholder="请输入年龄"
        />
    );
}

export function FormRulesDemo() {
    return (
        <Form
            initValues={{ username: '', age: undefined }}
            onSubmit={(values) => console.log('submit success', values)}
            onSubmitFail={(errors) => console.log('submit fail', errors)}
        >
            <Field
                field="username"
                label="用户名"
                rules={[{ required: true, message: '用户名不能为空' }]}
                Comp={FormUsernameInput}
            />
            <Field
                field="age"
                label="年龄"
                rules={[{ required: true, message: '年龄不能为空' }, { min: 18, message: '未满 18 岁' }]}
                Comp={FormAgeInput}
            />
            <Space>
                <Button htmlType="submit">提交</Button>
                <Button htmlType="reset">重置</Button>
            </Space>
        </Form>
    );
}
