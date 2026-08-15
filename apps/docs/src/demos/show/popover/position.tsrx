import { Popover, Button, Space } from '@lotus/ripple';
import type { FloatingPosition } from '@lotus/ripple';

const POSITIONS: FloatingPosition[] = ['top', 'left', 'right', 'bottom'];

export function PopoverPositionDemo() @{
    <Space>
        @for (const position of POSITIONS; key position) {
            <Popover trigger="click" position={position} content={<div style={{ padding: '8px 4px' }}>{position}</div>}>
                <Button theme="outline">{position}</Button>
            </Popover>
        }
    </Space>
}
