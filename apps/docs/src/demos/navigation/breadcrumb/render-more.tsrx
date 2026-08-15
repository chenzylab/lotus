import { Breadcrumb, Popover } from '@lotus/ripple';
import type { NormalizedRoute } from '@lotus/ripple';
import { IconMore } from '@lotus/icons';

const SEPARATOR = '-';

function RestRoutesContent({ restRoutes }: { restRoutes: NormalizedRoute[] }) {
    return <>
        @for (const item of restRoutes; index idx; key item.name) {
            <span>
                {item.name}
                @if (idx !== restRoutes.length - 1) {
                    <span style={{ color: 'var(--lotus-color-text-2)', marginRight: '6px' }}>{SEPARATOR}</span>
                }
            </span>
        }
    </>;
}

function renderMore(restRoutes: NormalizedRoute[]) {
    return <Popover content={<RestRoutesContent restRoutes={restRoutes} />} style={{ padding: '12px' }} showArrow>
        <IconMore />
    </Popover>;
}

export function RenderMoreBreadcrumbDemo() {
    return <Breadcrumb
        renderMore={renderMore}
        onClick={(item, e) => console.log(item, e)}
        routes={['首页', '当层级很多的时候', '又一层', '再一层', '上上一层', '上一层', '详情页']}
    />;
}
