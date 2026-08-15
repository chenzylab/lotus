import { Tabs } from '@lotus/ripple';
import type { TabItem } from '@lotus/ripple';
import { IconFile, IconGlobe, IconHelpCircle } from '@lotus/icons';

const TAB_LIST: TabItem[] = [
    { itemKey: '1', tab: '文档', icon: <IconFile />, render: () => <div style={{ padding: '16px 0' }}>文档</div> },
    { itemKey: '2', tab: '快速起步', icon: <IconGlobe />, render: () => <div style={{ padding: '16px 0' }}>快速起步</div> },
    { itemKey: '3', tab: '帮助', icon: <IconHelpCircle />, render: () => <div style={{ padding: '16px 0' }}>帮助</div> },
];

export function TabsIconDemo() {
    return <Tabs tabList={TAB_LIST} />;
}
