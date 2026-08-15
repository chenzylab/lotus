import { Button, Space } from '@lotus/ripple';

export function ButtonThemeDemo() {
    return <div>
        <div style={{ marginBottom: '12px' }}>
            <Space>
                <Button type="primary" theme="solid">主要按钮</Button>
                <Button type="secondary" theme="solid">次要按钮</Button>
                <Button type="warning" theme="solid">警示按钮</Button>
                <Button type="danger" theme="solid">危险按钮</Button>
            </Space>
        </div>
        <div style={{ marginBottom: '12px' }}>
            <Space>
                <Button type="primary" theme="light">主要按钮</Button>
                <Button type="secondary" theme="light">次要按钮</Button>
                <Button type="warning" theme="light">警示按钮</Button>
                <Button type="danger" theme="light">危险按钮</Button>
            </Space>
        </div>
        <div style={{ marginBottom: '12px' }}>
            <Space>
                <Button type="primary" theme="outline">主要按钮</Button>
                <Button type="secondary" theme="outline">次要按钮</Button>
                <Button type="warning" theme="outline">警示按钮</Button>
                <Button type="danger" theme="outline">危险按钮</Button>
            </Space>
        </div>
        <div>
            <Space>
                <Button type="primary" theme="borderless">主要按钮</Button>
                <Button type="secondary" theme="borderless">次要按钮</Button>
                <Button type="warning" theme="borderless">警示按钮</Button>
                <Button type="danger" theme="borderless">危险按钮</Button>
            </Space>
        </div>
    </div>;
}
