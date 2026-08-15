import { Tooltip, Button } from '@lotus/ripple';

export function TooltipNoArrowDemo() {
    return <Tooltip content="无箭头提示" showArrow={false}>
        <Button theme="outline">无箭头</Button>
    </Tooltip>;
}
