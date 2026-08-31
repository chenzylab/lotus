import { Notification, Button, Space, TypographyText } from '@lotus/ripple';
import { track } from 'ripple';

export function CallbackNotificationDemo() @{
    let &[log] = track('等待触发');

    <Space>
        <Button onClick={() => Notification.info({
            title: '点我触发 onClick',
            content: '点击卡片本身（非关闭按钮）',
            onClick: () => { log = '触发了 onClick'; },
            onClose: () => { log = '触发了 onClose'; },
            onCloseClick: () => { log = '触发了 onCloseClick'; },
        })}>
            展示通知
        </Button>
        <TypographyText type="secondary" aria-label="回调触发日志">{log}</TypographyText>
    </Space>
}
