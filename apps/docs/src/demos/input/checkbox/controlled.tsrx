import { track } from 'ripple';
import { Checkbox, Button, Space } from '@lotus/ripple';

export function CheckboxControlledDemo() @{
    let &[checked] = track<boolean>(false);

    <Space>
        <Checkbox checked={checked} onChange={(next: boolean) => { checked = next; }}>受控 Checkbox</Checkbox>
        <Button onClick={() => { checked = !checked; }}>切换</Button>
    </Space>
}
