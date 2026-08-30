import { Toast, Button, Space } from '@lotus/ripple';

export function StackToastDemo() @{
    <Space>
        <Button onClick={() => { Toast.info({ content: '消息一', stack: true }); Toast.info({ content: '消息二', stack: true }); Toast.info({ content: '消息三', stack: true }); }}>
            连续触发 3 条堆叠 Toast
        </Button>
        <Button onClick={() => Toast.destroyAll()}>destroyAll</Button>
    </Space>
}
