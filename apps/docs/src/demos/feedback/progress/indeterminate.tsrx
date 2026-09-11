import { Progress } from '@lotus/ripple';

export function IndeterminateProgressDemo() @{
    <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
        <Progress indeterminate aria-label="line 不确定态进度条" style={{ width: '200px' }} />
        <Progress indeterminate type="circle" aria-label="circle 不确定态进度条" />
    </div>
}
