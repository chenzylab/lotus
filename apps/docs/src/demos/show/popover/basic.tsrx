import { Popover, Button } from '@lotus/ripple';

export function PopoverBasicDemo() {
    return <Popover trigger="click" content={<div style={{ padding: '8px 4px' }}>这是气泡卡片的内容</div>}>
        <Button theme="outline">点击弹出</Button>
    </Popover>;
}
