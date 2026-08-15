import { Tabs } from '@lotus/ripple';
import type { TabItem } from '@lotus/ripple';

const TAB_LIST: TabItem[] = [
    { itemKey: 'tab1', tab: '标签页一', render: () => <div style={{ padding: '16px 0' }}>内容一</div> },
    { itemKey: 'tab2', tab: '标签页二', render: () => <div style={{ padding: '16px 0' }}>内容二</div> },
    { itemKey: 'tab3', tab: '标签页三', render: () => <div style={{ padding: '16px 0' }}>内容三</div> },
];

export function TabsBasicDemo() {
    return <Tabs tabList={TAB_LIST} onChange={(key: string) => console.log('tab changed', key)} />;
}
