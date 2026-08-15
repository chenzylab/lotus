import { Avatar, Space } from '@lotus/ripple';

export function AvatarGapDemo() {
    return <Space>
        <Avatar color="blue">用户名</Avatar>
        <Avatar color="blue" gap={0}>用户名</Avatar>
        <Avatar color="blue" gap={8}>用户名</Avatar>
    </Space>;
}
