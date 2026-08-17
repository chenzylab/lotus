import { track } from 'ripple';
import { InputNumber, Button, Space } from '@lotus/ripple';

export function InputNumberControlledDemo() @{
    let &[value] = track<number>(0);

    <Space>
        <InputNumber value={value} onChange={(next) => { if (next !== undefined) value = next; }} aria-label="受控示例" />
        <Button onClick={() => { value = value + 10; }}>加 10</Button>
    </Space>
}
