import { Rating } from '@lotus/ripple';

export function RatingSizeDisabledDemo() @{
    <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
        <Rating size="small" defaultValue={4} aria-label="小尺寸评分" />
        <Rating disabled defaultValue={3} aria-label="禁用评分" />
    </div>
}
