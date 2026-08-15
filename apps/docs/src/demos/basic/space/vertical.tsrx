import { Space, Button } from '@lotus/ripple';

export function VerticalSpaceDemo() {
    return <Space vertical>
        <Button theme="solid" type="primary">按钮</Button>
        <Button theme="solid" type="primary">按钮</Button>
        <Button theme="solid" type="primary">按钮</Button>
        <Button theme="solid" type="primary">按钮</Button>
    </Space>;
}
