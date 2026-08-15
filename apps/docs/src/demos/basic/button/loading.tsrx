import { Button, Space } from '@lotus/ripple';

export function ButtonLoadingDemo() {
    return <Space>
        <Button type="primary" theme="solid" loading>提交中</Button>
        <Button type="tertiary" loading>加载中</Button>
    </Space>;
}
