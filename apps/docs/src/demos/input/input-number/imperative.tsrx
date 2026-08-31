import { InputNumber, Button, Space } from '@lotus/ripple';
import type { InputNumberApi } from '@lotus/ripple';

export function ImperativeInputNumberDemo() @{
    let api: InputNumberApi | null = null;

    <Space>
        <InputNumber getInputNumberApi={(a: InputNumberApi) => { api = a; }} defaultValue={0} style={{ width: '200px' }} />
        <Button onClick={() => api?.focus()}>聚焦</Button>
        <Button onClick={() => api?.blur()}>失焦</Button>
    </Space>
}
