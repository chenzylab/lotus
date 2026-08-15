import { track } from 'ripple';
import { Tag, Button, Space } from '@lotus/ripple';

export function TagVisibleDemo() @{
    let &[visible] = track<boolean>(true);

    <Space>
        <Tag visible={visible} color="orange">受控可见性标签</Tag>
        <Button onClick={() => { visible = !visible; }}>切换可见性</Button>
    </Space>
}
