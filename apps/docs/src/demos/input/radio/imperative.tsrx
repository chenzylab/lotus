import { Radio, Button, Space } from '@lotus/ripple';
import type { RadioApi } from '@lotus/ripple';

export function ImperativeRadioDemo() @{
    let radioApi: RadioApi | null = null;

    <Space>
        <Radio addonId="radio-addon-id-example" extraId="radio-extra-id-example" extra="自定义 addonId/extraId">
            自定义 id 示例
        </Radio>
        <Radio autoFocus>autoFocus 示例</Radio>
        <Radio getRadioApi={(api: RadioApi) => { radioApi = api; }}>命令式 focus/blur</Radio>
        <Button onClick={() => radioApi?.focus()}>聚焦</Button>
        <Button onClick={() => radioApi?.blur()}>失焦</Button>
    </Space>
}
