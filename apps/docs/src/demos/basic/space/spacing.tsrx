import { Space, Button, Tabs } from '@lotus/ripple';
import type { TabItem } from '@lotus/ripple';

export function SpacingSpaceDemo() {
    const tabList: TabItem[] = [
        {
            itemKey: '1',
            tab: 'tight',
            render: () => <Space spacing="tight" style={{ marginTop: '15px' }}>
                <Button theme="solid" type="primary">按钮</Button>
                <Button theme="solid" type="primary">按钮</Button>
                <Button theme="solid" type="primary">按钮</Button>
                <Button theme="solid" type="primary">按钮</Button>
            </Space>,
        },
        {
            itemKey: '2',
            tab: 'medium',
            render: () => <Space spacing="medium" style={{ marginTop: '15px' }}>
                <Button theme="solid" type="primary">按钮</Button>
                <Button theme="solid" type="primary">按钮</Button>
                <Button theme="solid" type="primary">按钮</Button>
                <Button theme="solid" type="primary">按钮</Button>
            </Space>,
        },
        {
            itemKey: '3',
            tab: 'loose',
            render: () => <Space spacing="loose" style={{ marginTop: '15px' }}>
                <Button theme="solid" type="primary">按钮</Button>
                <Button theme="solid" type="primary">按钮</Button>
                <Button theme="solid" type="primary">按钮</Button>
                <Button theme="solid" type="primary">按钮</Button>
            </Space>,
        },
        {
            itemKey: '4',
            tab: 'array',
            render: () => <Space spacing={[8, 16]} wrap style={{ marginTop: '15px' }}>
                <Button theme="solid" type="primary">按钮</Button>
                <Button theme="solid" type="primary">按钮</Button>
                <Button theme="solid" type="primary">按钮</Button>
                <Button theme="solid" type="primary">按钮</Button>
                <Button theme="solid" type="primary">按钮</Button>
                <Button theme="solid" type="primary">按钮</Button>
                <Button theme="solid" type="primary">按钮</Button>
                <Button theme="solid" type="primary">按钮</Button>
                <Button theme="solid" type="primary">按钮</Button>
                <Button theme="solid" type="primary">按钮</Button>
            </Space>,
        },
    ];

    return <Tabs type="line" tabList={tabList} />;
}
