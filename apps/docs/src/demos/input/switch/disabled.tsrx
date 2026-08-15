import { Switch, Space } from '@lotus/ripple';

export function SwitchDisabledDemo() {
    return <Space>
        <Switch disabled />
        <Switch disabled defaultChecked />
    </Space>;
}
