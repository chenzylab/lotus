import { Avatar, Space } from '@lotus/ripple';
import type { AvatarSize } from '@lotus/ripple';

const SIZES: AvatarSize[] = ['extra-extra-small', 'extra-small', 'small', 'default', 'medium', 'large', 'extra-large'];

export function AvatarSizeDemo() @{
    <Space>
        @for (const size of SIZES; key size) {
            <Avatar size={size} color="orange">A</Avatar>
        }
    </Space>
}
