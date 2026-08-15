import { Breadcrumb } from '@lotus/ripple';

export function CollapseBreadcrumbDemo() {
    return <Breadcrumb routes={['首页', '当层级很多的时候', '又一层', '再一层', '上上一层', '上一层', '详情页']} />;
}
