import { Tooltip, Button, Space } from '@lotus/ripple';

export function TooltipTriggerDemo() {
    return <Space>
        <Tooltip content="hover 触发" trigger="hover">
            <Button theme="outline">hover</Button>
        </Tooltip>
        <Tooltip content="click 触发" trigger="click">
            <Button theme="outline">click</Button>
        </Tooltip>
        <Tooltip content="focus 触发" trigger="focus">
            <Button theme="outline">focus</Button>
        </Tooltip>
    </Space>;
}
