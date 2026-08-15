import { Tabs } from '@lotus/ripple';
import type { TabItem } from '@lotus/ripple';

const TAB_LIST: TabItem[] = [
    { itemKey: 'tab1', tab: '标签页一', render: () => <div style={{ padding: '0 16px' }}>内容一</div> },
    { itemKey: 'tab2', tab: '标签页二', render: () => <div style={{ padding: '0 16px' }}>内容二</div> },
    { itemKey: 'tab3', tab: '标签页三', render: () => <div style={{ padding: '0 16px' }}>内容三</div> },
];

export function TabsVerticalDemo() {
    return <Tabs tabPosition="left" tabList={TAB_LIST} />;
}
