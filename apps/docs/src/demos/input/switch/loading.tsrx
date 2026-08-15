import { Switch, Space } from '@lotus/ripple';

export function SwitchLoadingDemo() {
    return <Space>
        <Switch loading />
        <Switch loading checked />
    </Space>;
}
