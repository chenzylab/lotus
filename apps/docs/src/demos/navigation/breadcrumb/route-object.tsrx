import { Breadcrumb } from '@lotus/ripple';
import type { BreadcrumbRoute } from '@lotus/ripple';
import { IconHome, IconArticle } from '@lotus/icons';

export function RouteObjectBreadcrumbDemo() {
    const routes: Array<BreadcrumbRoute | string> = [
        { path: '/', href: '/', icon: IconHome },
        { path: '/breadcrumb', href: '/navigation/breadcrumb', name: 'breadcrumb', icon: IconArticle },
        'with icon',
    ];
    return <div>
        <Breadcrumb routes={['Semi-ui', 'Breadcrumb', 'Default']} />
        <br />
        <Breadcrumb routes={routes} />
        <br />
        <Breadcrumb routes={['首页', '当这个页面标题很长时需要省略', '详情页']} />
    </div>;
}
