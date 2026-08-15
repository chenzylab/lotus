import { Switch, Space } from '@lotus/ripple';

export function SwitchTextDemo() {
    return <Space>
        <Switch checkedText="开" uncheckedText="关" defaultChecked />
        <Switch checkedText="ON" uncheckedText="OFF" />
    </Space>;
}
