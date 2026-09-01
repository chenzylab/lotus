import { Rating, Button, Space } from '@lotus/ripple';
import type { RatingApi } from '@lotus/ripple';

export function RatingApiDemo() @{
    let ratingApiRef: RatingApi | null = null;

    <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
        <Rating
            getRatingApi={(api: RatingApi) => { ratingApiRef = api; }}
            aria-label="命令式聚焦评分"
        />
        <Space>
            <Button onClick={() => ratingApiRef?.focus()}>聚焦</Button>
            <Button onClick={() => ratingApiRef?.blur()}>失焦</Button>
        </Space>
    </div>
}
