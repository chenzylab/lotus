import { track } from 'ripple';
import { Radio, Button, Space } from '@lotus/ripple';

export function RadioControlledDemo() @{
    let &[checked] = track<boolean>(false);

    <Space>
        <Radio checked={checked} onChange={(next: boolean) => { checked = next; }}>受控 Radio</Radio>
        <Button onClick={() => { checked = !checked; }}>切换</Button>
    </Space>
}
