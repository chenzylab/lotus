import { Tag, Space } from '@lotus/ripple';
import type { TagColor } from '@lotus/ripple';

const COLORS: TagColor[] = [
    'amber', 'blue', 'cyan', 'green', 'grey', 'indigo', 'lightBlue', 'lightGreen',
    'lime', 'orange', 'pink', 'purple', 'red', 'teal', 'violet', 'yellow', 'white',
];

export function TagColorDemo() @{
    <Space wrap>
        @for (const color of COLORS; key color) {
            <Tag color={color}>{color}</Tag>
        }
    </Space>
}
