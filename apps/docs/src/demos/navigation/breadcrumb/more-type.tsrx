import { Breadcrumb } from '@lotus/ripple';

export function MoreTypeBreadcrumbDemo() {
    return <Breadcrumb moreType="popover" routes={['首页', '当层级很多的时候', '又一层', '再一层', '上上一层', '上一层', '详情页']} />;
}
