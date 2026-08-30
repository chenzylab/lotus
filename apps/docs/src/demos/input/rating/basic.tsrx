import { track } from 'ripple';
import { Rating, TypographyText } from '@lotus/ripple';

export function RatingBasicDemo() @{
    let &[log] = track<string>('');

    <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
        <Rating
            defaultValue={3}
            onChange={(v: number) => { log = `评分变为 ${v}`; }}
            aria-label="基础评分"
        />
        <TypographyText type="secondary">{log}</TypographyText>
    </div>
}
