import { Tooltip, Button, Space } from '@lotus/ripple';
import type { FloatingPosition } from '@lotus/ripple';

const POSITIONS: FloatingPosition[] = [
    'top', 'topLeft', 'topRight',
    'left', 'leftTop', 'leftBottom',
    'right', 'rightTop', 'rightBottom',
    'bottom', 'bottomLeft', 'bottomRight',
];

export function TooltipPositionDemo() @{
    <Space wrap>
        @for (const position of POSITIONS; key position) {
            <Tooltip content={position} position={position}>
                <Button theme="outline">{position}</Button>
            </Tooltip>
        }
    </Space>
}
