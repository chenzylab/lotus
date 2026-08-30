import { Button, Space, Toast } from '@lotus/ripple';

export function BasicToastDemo() @{
    <Space>
        <Button onClick={() => Toast.info('这是一条 info 提示')}>Toast.info</Button>
        <Button onClick={() => Toast.success('操作成功')}>Toast.success</Button>
        <Button onClick={() => Toast.warning('警告信息')}>Toast.warning</Button>
        <Button onClick={() => Toast.error('出错了')}>Toast.error</Button>
    </Space>
}
