import { Tooltip, Button } from '@lotus/ripple';

export function TooltipBasicDemo() {
    return <Tooltip content="这是提示文字">
        <Button>悬浮查看提示</Button>
    </Tooltip>;
}
