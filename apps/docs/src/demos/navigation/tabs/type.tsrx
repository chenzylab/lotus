import { Tabs } from '@lotus/ripple';
import type { TabItem } from '@lotus/ripple';

const TAB_LIST: TabItem[] = [
    { itemKey: 'tab1', tab: '标签页一', render: () => <div style={{ padding: '16px 0' }}>内容一</div> },
    { itemKey: 'tab2', tab: '标签页二', render: () => <div style={{ padding: '16px 0' }}>内容二</div> },
];

export function TabsTypeDemo() {
    return <div>
        <div style={{ marginBottom: '24px' }}>
            <Tabs type="line" tabList={TAB_LIST} />
        </div>
        <div style={{ marginBottom: '24px' }}>
            <Tabs type="card" tabList={TAB_LIST} />
        </div>
        <div>
            <Tabs type="button" tabList={TAB_LIST} />
        </div>
    </div>;
}
