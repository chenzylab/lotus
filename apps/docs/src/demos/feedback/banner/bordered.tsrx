import { Banner, Space } from '@lotus/ripple';

export function BorderedBannerDemo() @{
    <Space vertical style={{ width: '100%' }}>
        <Banner type="success" title="操作成功" bordered fullMode={false} />
        <Banner type="warning" title="警告" description="bordered + fullMode=false 卡片模式" bordered fullMode={false} />
    </Space>
}
