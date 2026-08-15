import { track } from 'ripple';
import { Switch, Button, Space } from '@lotus/ripple';

export function SwitchControlledDemo() @{
    let &[checked] = track<boolean>(false);

    <Space>
        <Switch checked={checked} onChange={(next: boolean) => { checked = next; }} />
        <Button onClick={() => { checked = !checked; }}>切换</Button>
    </Space>
}
