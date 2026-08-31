import { Popover, Button, Space } from '@lotus/ripple';

export function ArrowPointAtCenterPopoverDemo() {
    return <Space>
        <Popover trigger="click" showArrow arrowPointAtCenter content={<div style={{ padding: '8px 4px' }}>箭头指向元素中心</div>}>
            <Button theme="outline">arrowPointAtCenter=true（默认）</Button>
        </Popover>
        <Popover trigger="click" showArrow arrowPointAtCenter={false} content={<div style={{ padding: '8px 4px' }}>箭头挪到边缘</div>}>
            <Button theme="outline">arrowPointAtCenter=false</Button>
        </Popover>
    </Space>;
}
