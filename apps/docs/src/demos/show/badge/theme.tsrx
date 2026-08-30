import { Badge, Space } from '@lotus/ripple';

export function ThemeBadgeDemo() @{
    <Space vertical align="start" style={{ gap: '12px' }}>
        <Space>
            <Badge count={5} theme="solid" />
            <Badge count={5} theme="light" />
            <Badge count={5} theme="inverted" />
        </Space>
        <Space>
            <Badge count={5} type="success" />
            <Badge count={5} type="warning" />
            <Badge count={5} type="danger" />
            <Badge count={5} type="secondary" />
            <Badge count={5} type="tertiary" />
        </Space>
    </Space>
}
