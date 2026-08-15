import { Popover, Button, Space } from '@lotus/ripple';

export function PopoverConditionDemo() {
    return <Space>
        <Popover trigger="click" condition={true} content={<div style={{ padding: '8px 4px' }}>正常展示</div>}>
            <Button theme="outline">condition=true</Button>
        </Popover>
        <Popover trigger="click" condition={false} content={<div style={{ padding: '8px 4px' }}>不会展示</div>}>
            <Button theme="outline">condition=false</Button>
        </Popover>
    </Space>;
}
