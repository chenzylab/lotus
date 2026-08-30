import { Banner, Space } from '@lotus/ripple';

export function BasicBannerDemo() @{
    <Space vertical style={{ width: '100%' }}>
        <Banner type="info" title="信息提示" description="这是一条 info 类型的通栏提示" />
        <Banner type="success" title="操作成功" description="这是一条 success 类型的通栏提示" />
        <Banner type="warning" title="警告" description="这是一条 warning 类型的通栏提示" />
        <Banner type="danger" title="错误" description="这是一条 danger 类型的通栏提示" />
    </Space>
}
