import { track } from 'ripple';
import { Popover, Button, Space } from '@lotus/ripple';

export function PopoverControlledDemo() @{
    let &[visible] = track<boolean>(false);

    <Space>
        <Popover trigger="custom" visible={visible} content={<div style={{ padding: '8px 4px' }}>受控内容</div>}>
            <Button theme="outline">受控 Popover</Button>
        </Popover>
        <Button onClick={() => { visible = !visible; }}>切换显隐</Button>
    </Space>
}
