import { Avatar, Space } from '@lotus/ripple';

export function AvatarBorderDemo() {
    return <Space>
        <Avatar color="green" border>静态边框</Avatar>
        <Avatar color="red" border={{ color: '#f2a44b' }}>自定义边框色</Avatar>
    </Space>;
}
