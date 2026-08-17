import { InputNumber, Space } from '@lotus/ripple';

export function InputNumberSizeDemo() {
    return (
        <Space>
            <InputNumber size="large" defaultValue={0} aria-label="large" />
            <InputNumber size="default" defaultValue={0} aria-label="default" />
            <InputNumber size="small" defaultValue={0} aria-label="small" />
        </Space>
    );
}
