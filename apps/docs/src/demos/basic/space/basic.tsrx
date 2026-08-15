import { Space, Button, Switch } from '@lotus/ripple';

export function BasicSpaceDemo() {
    return <Space>
        <Switch defaultChecked />
        <Button type="secondary">次要</Button>
        <Button type="tertiary">第三</Button>
        <Button type="warning">警告</Button>
    </Space>;
}
