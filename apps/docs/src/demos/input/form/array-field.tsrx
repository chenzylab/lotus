import { Form, ArrayField, Field, Input, Button, Space } from '@lotus/ripple';
import type { ArrayFieldRenderProps, FieldRenderProps } from '@lotus/ripple';

function ContactNameInput(&{ value, disabled, onChange, onBlur, 'aria-label': ariaLabel }: FieldRenderProps) {
    return (
        <Input
            value={value ?? ''}
            disabled={disabled}
            onChange={(v) => onChange(v)}
            onBlur={onBlur}
            aria-label={ariaLabel}
            placeholder="联系人姓名"
        />
    );
}

function ContactsArrayFieldContent(&{ arrayFields, add, addWithInitValue }: ArrayFieldRenderProps) @{
    <Space vertical align="start" style={{ width: '100%', gap: '8px' }}>
        @for (const item of arrayFields; key item.key) {
            <Space>
                <Field field={item.field} noLabel Comp={ContactNameInput} />
                <Button onClick={item.remove}>删除</Button>
            </Space>
        }
        <Space>
            <Button onClick={() => add()}>新增联系人</Button>
            <Button onClick={() => addWithInitValue('预填联系人')}>新增并预填</Button>
        </Space>
    </Space>
}

export function FormArrayFieldDemo() {
    return (
        <Form initValues={{ contacts: ['张三'] }}>
            <ArrayField field="contacts" Comp={ContactsArrayFieldContent} />
        </Form>
    );
}
