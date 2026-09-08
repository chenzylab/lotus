import { Tabs, TabPane } from '@lotus/ripple';

export function DeclarativeTabsDemo() @{
    <Tabs defaultActiveKey="2" onChange={(key: string) => console.log('tab changed', key)}>
        <TabPane itemKey="1" tab="标签一">内容一</TabPane>
        <TabPane itemKey="2" tab="标签二">内容二</TabPane>
        <TabPane itemKey="3" tab="禁用标签" disabled>不可达</TabPane>
    </Tabs>
}
