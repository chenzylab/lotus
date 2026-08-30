import { track } from 'ripple';
import { Pagination } from '@lotus/ripple';

export function FullPaginationDemo() @{
    let &[currentPage] = track<number>(3);
    let &[pageSize] = track<number>(10);

    <Pagination
        total={95}
        currentPage={currentPage}
        pageSize={pageSize}
        showSizeChanger
        showQuickJumper
        showTotal
        onPageChange={(p) => { currentPage = p; }}
        onPageSizeChange={(s) => { pageSize = s; }}
        aria-label="完整分页器（含每页条数切换、快速跳转、总数展示）"
    />
}
