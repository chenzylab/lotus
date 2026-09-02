import { Pagination } from '@lotus/ripple';

export function AdvancedPaginationDemo() @{
    <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
        <Pagination
            total={500}
            defaultCurrentPage={10}
            prevText="上一页"
            nextText="下一页"
            popoverPosition="bottom"
        />
        <Pagination total={5} defaultCurrentPage={1} hideOnSinglePage />
        <Pagination total={500} defaultCurrentPage={10} size="small" hoverShowPageSelect />
    </div>
}
