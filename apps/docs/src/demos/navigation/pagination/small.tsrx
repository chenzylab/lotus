import { Pagination } from '@lotus/ripple';

export function SmallPaginationDemo() @{
    <Pagination total={500} defaultCurrentPage={10} size="small" aria-label="小尺寸分页器（省略号截断）" />
}
