import { Input, Space } from '@lotus/ripple';

export function InputSizeDemo() {
    return <Space vertical align="start">
        <Input size="large" placeholder="large" />
        <Input size="default" placeholder="default" />
        <Input size="small" placeholder="small" />
    </Space>;
}
