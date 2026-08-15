import { Popover, Button } from '@lotus/ripple';

export function PopoverArrowDemo() {
    return <Popover trigger="click" showArrow content={<div style={{ padding: '8px 4px' }}>带箭头的气泡卡片</div>}>
        <Button theme="outline">显示小三角</Button>
    </Popover>;
}
