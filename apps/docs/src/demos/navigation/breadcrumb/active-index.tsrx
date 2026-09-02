import { Breadcrumb } from '@lotus/ripple';

export function ActiveIndexBreadcrumbDemo() {
    return <Breadcrumb activeIndex={1} routes={['首页', '组件（当前页）', '导航', '面包屑']} />;
}
