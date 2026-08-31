import { Checkbox, Button, Space } from '@lotus/ripple';
import type { CheckboxApi } from '@lotus/ripple';

export function ImperativeCheckboxDemo() @{
    let checkboxApi: CheckboxApi | null = null;

    <Space>
        <Checkbox addonId="checkbox-addon-id-example" extraId="checkbox-extra-id-example" extra="自定义 addonId/extraId">
            自定义 id 示例
        </Checkbox>
        <Checkbox getCheckboxApi={(api: CheckboxApi) => { checkboxApi = api; }}>命令式 focus/blur</Checkbox>
        <Button onClick={() => checkboxApi?.focus()}>聚焦</Button>
        <Button onClick={() => checkboxApi?.blur()}>失焦</Button>
    </Space>
}
