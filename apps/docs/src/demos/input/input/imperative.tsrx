import { Input, Button, Space } from '@lotus/ripple';
import type { InputApi } from '@lotus/ripple';
import { IconTickCircle } from '@lotus/icons';

export function ImperativeInputDemo() @{
    let inputApi: InputApi | null = null;

    <Space vertical align="start">
        <Input
            aria-label="带完整 ARIA 属性的输入框"
            aria-describedby="input-aria-hint-demo"
            aria-required
            defaultValue="ARIA 属性透传"
        />
        <Input clearIcon={<IconTickCircle />} showClear defaultValue="自定义清除图标" aria-label="自定义清除图标示例" />
        <Space>
            <Input getInputApi={(api: InputApi) => { inputApi = api; }} placeholder="命令式 focus/blur" aria-label="命令式 focus/blur 示例" />
            <Button onClick={() => inputApi?.focus()}>聚焦</Button>
            <Button onClick={() => inputApi?.blur()}>失焦</Button>
        </Space>
    </Space>
}
