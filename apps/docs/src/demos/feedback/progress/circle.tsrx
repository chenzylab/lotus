import { Progress } from '@lotus/ripple';

export function CircleProgressDemo() @{
    <div style={{ display: 'flex', gap: '16px', alignItems: 'center' }}>
        <Progress percent={70} type="circle" showInfo aria-label="circle 基础进度条" />
        <Progress percent={70} type="circle" size="small" showInfo aria-label="circle 小尺寸进度条" />
    </div>
}
