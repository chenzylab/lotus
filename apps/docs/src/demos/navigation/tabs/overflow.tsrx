import { Tabs } from '@lotus/ripple';
import type { TabItem } from '@lotus/ripple';

function manyTabList(count: number): TabItem[] {
    return Array.from({ length: count }, (_v, i) => ({
        itemKey: `tab-${i}`,
        tab: `标签 ${i + 1}`,
        render: () => <div style={{ padding: '16px 0' }}>面板 {i + 1} 内容</div>,
    }));
}

export function OverflowTabsDemo() @{
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
        <div style={{ width: '360px' }}>
            <Tabs tabList={manyTabList(15)} collapsible arrowPosition="both" />
        </div>
        <div style={{ width: '360px' }}>
            <Tabs tabList={manyTabList(10)} collapsible more={5} />
        </div>
    </div>
}
