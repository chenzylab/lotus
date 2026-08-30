import { track } from 'ripple';
import { Progress, Button } from '@lotus/ripple';

export function ControlledProgressDemo() @{
    let &[percent] = track<number>(30);

    <div style={{ width: '320px', display: 'flex', flexDirection: 'column', gap: '12px' }}>
        <Progress
            percent={percent}
            showInfo
            stroke={[
                { percent: 0, color: '#f93920' },
                { percent: 50, color: '#fc8800' },
                { percent: 100, color: '#3bb346' },
            ]}
            strokeGradient
            aria-label="多段渐变进度条（受控）"
            style={{ width: '100%' }}
        />
        <Button onClick={() => { percent = percent >= 100 ? 0 : percent + 20; }}>切换百分比</Button>
    </div>
}
