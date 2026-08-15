import { Button, Space } from '@lotus/ripple';

export function ButtonTypeDemo() {
    return <Space>
        <Button type="primary">主要按钮</Button>
        <Button type="secondary">次要按钮</Button>
        <Button type="tertiary">三级按钮</Button>
        <Button type="warning">警示按钮</Button>
        <Button type="danger">危险按钮</Button>
    </Space>;
}
