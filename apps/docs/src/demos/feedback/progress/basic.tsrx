import { Progress } from '@lotus/ripple';

export function BasicProgressDemo() @{
    <div style={{ width: '320px' }}>
        <Progress percent={30} showInfo aria-label="line 基础进度条" style={{ width: '100%' }} />
    </div>
}
