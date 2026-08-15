import { Breadcrumb } from '@lotus/ripple';
import type { BreadcrumbRoute } from '@lotus/ripple';
import { IconHome, IconArticle } from '@lotus/icons';

export function WithIconBreadcrumbDemo() {
    const routes: BreadcrumbRoute[] = [
        { icon: IconHome },
        { icon: IconArticle, name: 'Breadcrumb' },
        { name: 'With Icon' },
    ];
    return <Breadcrumb routes={routes} />;
}
