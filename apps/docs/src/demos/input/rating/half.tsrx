import { Rating } from '@lotus/ripple';

export function RatingHalfDemo() @{
    <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
        <Rating allowHalf defaultValue={2.5} count={10} aria-label="半星评分" />
    </div>
}
