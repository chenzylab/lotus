import { Switch, Space } from '@lotus/ripple';

export function SwitchSizeDemo() {
    return <Space>
        <Switch size="large" defaultChecked />
        <Switch size="default" defaultChecked />
        <Switch size="small" defaultChecked />
    </Space>;
}
