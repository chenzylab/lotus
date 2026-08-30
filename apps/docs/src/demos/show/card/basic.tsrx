import { Card, Button } from '@lotus/ripple';

export function BasicCardDemo() @{
    <div style={{ width: '320px' }}>
        <Card
            title="卡片标题"
            footer={<Button type="primary" theme="borderless">查看详情</Button>}
        >
            卡片内容区域，可放置任意内容。
        </Card>
    </div>
}
