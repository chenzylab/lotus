import { Notification, Button, Space } from '@lotus/ripple';

export function BasicNotificationDemo() @{
    <Space>
        <Button onClick={() => Notification.info({ title: '通知标题', content: '这是通知内容', position: 'topRight' })}>
            Notification.info（topRight）
        </Button>
        <Button onClick={() => Notification.success({ title: '成功', content: '操作已完成', position: 'bottomLeft' })}>
            Notification.success（bottomLeft）
        </Button>
        <Button onClick={() => Notification.destroyAll()}>destroyAll</Button>
    </Space>
}
