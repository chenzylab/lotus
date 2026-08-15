import { Input, Space } from '@lotus/ripple';

export function InputValidateStatusDemo() {
    return <Space vertical align="start">
        <Input validateStatus="warning" defaultValue="警示状态" />
        <Input validateStatus="error" defaultValue="错误状态" />
    </Space>;
}
