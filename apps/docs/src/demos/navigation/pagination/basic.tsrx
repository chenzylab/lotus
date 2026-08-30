import { track } from 'ripple';
import { Pagination } from '@lotus/ripple';

export function BasicPaginationDemo() @{
    let &[currentPage] = track<number>(3);

    <Pagination
        total={95}
        currentPage={currentPage}
        onPageChange={(p) => { currentPage = p; }}
        aria-label="基础分页器"
    />
}
