import { Notification, Button, Space } from '@lotus/ripple';

export function ThemeNotificationDemo() @{
    <Space>
        <Button onClick={() => Notification.info({ title: 'theme=normal', content: '默认纯色卡片', theme: 'normal' })}>
            theme=normal
        </Button>
        <Button onClick={() => Notification.info({ title: 'theme=light', content: '浅色填充样式', theme: 'light' })}>
            theme=light
        </Button>
        <Button onClick={() => Notification.destroyAll()}>destroyAll</Button>
    </Space>
}
