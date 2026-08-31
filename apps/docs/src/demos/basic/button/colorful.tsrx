import { Button, Space } from '@lotus/ripple';

export function ColorfulButtonDemo() @{
    <Space>
        <Button type="primary" theme="solid" colorful>primary solid</Button>
        <Button type="tertiary" theme="solid" colorful>tertiary solid</Button>
        <Button type="primary" theme="light" colorful>primary light</Button>
        <Button type="primary" theme="borderless" colorful>primary borderless</Button>
        <Button type="secondary" theme="solid" colorful>secondary（无效果）</Button>
    </Space>
}
