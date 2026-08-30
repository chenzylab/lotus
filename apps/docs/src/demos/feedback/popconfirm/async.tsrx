import { Popconfirm, Button } from '@lotus/ripple';

export function AsyncPopconfirmDemo() @{
    <Popconfirm
        title="提交前确认"
        onConfirm={() => new Promise<void>((resolve) => setTimeout(resolve, 600))}
    >
        <Button type="primary" theme="outline">提交（异步回调，600ms）</Button>
    </Popconfirm>
}
