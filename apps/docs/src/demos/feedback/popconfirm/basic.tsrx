import { Popconfirm, Button, Space } from '@lotus/ripple';

export function BasicPopconfirmDemo() @{
    <Space>
        <Popconfirm
            title="确认删除？"
            description="删除后无法恢复"
            onConfirm={() => console.log('popconfirm confirmed')}
            onCancel={() => console.log('popconfirm cancelled')}
        >
            <Button type="danger" theme="outline">删除</Button>
        </Popconfirm>
    </Space>
}
