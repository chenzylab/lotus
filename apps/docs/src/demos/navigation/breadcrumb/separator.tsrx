import { Breadcrumb } from '@lotus/ripple';
import { IconArrowRight } from '@lotus/icons';

export function SeparatorBreadcrumbDemo() {
    return <div>
        <Breadcrumb separator=">" routes={['Semi-ui', 'Breadcrumb', 'Default']} />
        <br />
        <Breadcrumb separator={<IconArrowRight />} routes={['Semi-ui', 'Breadcrumb', 'Default']} />
    </div>;
}
