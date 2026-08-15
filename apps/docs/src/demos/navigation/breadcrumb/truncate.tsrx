import { Breadcrumb } from '@lotus/ripple';

export function TruncateBreadcrumbDemo() {
    const routes = ['首页', '当这个页面标题很长很长很长时需要省略', '详情页'];
    return <div>
        <p style={{ fontSize: 'var(--lotus-font-label-size)' }}>默认行为</p>
        <Breadcrumb routes={routes} />
        <br />
        <p style={{ fontSize: 'var(--lotus-font-label-size)' }}>省略但不显示 Tooltip</p>
        <Breadcrumb showTooltip={false} routes={routes} />
        <br />
        <p style={{ fontSize: 'var(--lotus-font-label-size)' }}>不截断</p>
        <Breadcrumb showTooltip={{ width: 'auto' }} routes={routes} />
        <br />
        <p style={{ fontSize: 'var(--lotus-font-label-size)' }}>从标题中间开始省略</p>
        <Breadcrumb showTooltip={{ ellipsisPos: 'middle' }} routes={routes} />
    </div>;
}
