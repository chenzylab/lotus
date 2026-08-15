import { Avatar, Space } from '@lotus/ripple';

export function AvatarSlotDemo() {
    return <Space>
        <Avatar
            color="orange"
            size="large"
            topSlot={{ text: 'VIP', gradientStart: '#f2a44b', gradientEnd: '#e8542f' }}
        >
            YJ
        </Avatar>
        <Avatar
            color="blue"
            size="large"
            bottomSlot={{ text: '在线', bgColor: '#33bb66', textColor: '#fff' }}
        >
            YJ
        </Avatar>
    </Space>;
}
