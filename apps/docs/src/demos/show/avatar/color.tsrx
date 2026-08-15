import { Avatar, Space } from '@lotus/ripple';
import type { AvatarColor } from '@lotus/ripple';

const COLORS: AvatarColor[] = ['red', 'light-blue', 'orange', 'green', 'purple', 'grey', 'white'];

export function AvatarColorDemo() @{
    <Space>
        @for (const color of COLORS; key color) {
            <Avatar color={color}>YJ</Avatar>
        }
    </Space>
}
