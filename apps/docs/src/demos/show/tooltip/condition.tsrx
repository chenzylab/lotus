import { Tooltip, Button, Space } from '@lotus/ripple';

export function TooltipConditionDemo() {
    return <Space>
        <Tooltip content="正常展示" condition={true}>
            <Button theme="outline">condition=true</Button>
        </Tooltip>
        <Tooltip content="不会展示" condition={false}>
            <Button theme="outline">condition=false</Button>
        </Tooltip>
    </Space>;
}
