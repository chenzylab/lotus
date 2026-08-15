import { track } from 'ripple';
import { Tooltip, Button, Space } from '@lotus/ripple';

export function TooltipCustomDemo() @{
    let &[visible] = track<boolean>(false);

    <Space>
        <Tooltip content="受控显隐" trigger="custom" visible={visible}>
            <Button theme="outline">受控 Tooltip</Button>
        </Tooltip>
        <Button onClick={() => { visible = !visible; }}>切换显隐</Button>
    </Space>
}
