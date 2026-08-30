import { track } from 'ripple';
import { ConfigProvider, Button, Pagination } from '@lotus/ripple';

export function DirectionConfigProviderDemo() @{
    let &[direction] = track<'ltr' | 'rtl'>('ltr');

    <ConfigProvider direction={direction}>
        <div style={{ padding: '16px', border: '1px solid var(--lotus-color-border)', borderRadius: 'var(--lotus-border-radius-medium)' }}>
            <Button onClick={() => { direction = direction === 'rtl' ? 'ltr' : 'rtl'; }}>
                {direction === 'rtl' ? '切换到 ltr' : '切换到 rtl'}
            </Button>
            <div style={{ marginTop: '12px' }}>
                <Pagination total={95} defaultCurrentPage={1} aria-label="ConfigProvider direction 示例 Pagination" />
            </div>
        </div>
    </ConfigProvider>
}
