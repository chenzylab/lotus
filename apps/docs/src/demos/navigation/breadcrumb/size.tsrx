import { Breadcrumb } from '@lotus/ripple';
import type { BreadcrumbRoute } from '@lotus/ripple';
import { IconHome } from '@lotus/icons';

export function SizeBreadcrumbDemo() {
    const routes: BreadcrumbRoute[] = [{ icon: IconHome }, { name: 'Breadcrumb' }, { name: 'Loose' }];
    return <div>
        <Breadcrumb compact routes={routes} />
        <br />
        <Breadcrumb compact={false} routes={routes} />
    </div>;
}
