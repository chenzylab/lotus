import { Tabs } from '@lotus/ripple';
import type { TabItem } from '@lotus/ripple';

const TAB_LIST: TabItem[] = [
    { itemKey: 'tab1', tab: '标签页一', closable: true, render: () => <div style={{ padding: '16px 0' }}>内容一</div> },
    { itemKey: 'tab2', tab: '标签页二', closable: true, render: () => <div style={{ padding: '16px 0' }}>内容二</div> },
];

export function TabsClosableDemo() {
    return <Tabs tabList={TAB_LIST} onTabClose={(key: string) => console.log('tab close requested', key)} />;
}
