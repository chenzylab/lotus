import { Button, Space } from '@lotus/ripple';

export function ButtonDisabledDemo() {
    return <Space>
        <Button type="primary" theme="solid" disabled>主要按钮</Button>
        <Button type="primary" theme="light" disabled>主要按钮</Button>
        <Button type="primary" theme="outline" disabled>主要按钮</Button>
        <Button type="primary" theme="borderless" disabled>主要按钮</Button>
    </Space>;
}
