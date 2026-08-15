import { Button, Space } from '@lotus/ripple';

export function ButtonSizeDemo() {
    return <Space>
        <Button type="primary" size="large">大按钮</Button>
        <Button type="primary" size="default">默认按钮</Button>
        <Button type="primary" size="small">小按钮</Button>
    </Space>;
}
