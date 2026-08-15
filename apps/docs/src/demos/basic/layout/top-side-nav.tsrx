import { Layout, Header, Footer, Sider, Content, Nav, NavHeader, NavFooter, Button, Breadcrumb, Skeleton, SkeletonParagraph, Avatar } from '@lotus/ripple';
import type { NavItemInput } from '@lotus/ripple';
import { IconLotusLogo, IconHome, IconHistogram, IconLive, IconSetting, IconBell, IconHelpCircle } from '@lotus/icons';

export function TopSideNavLayoutDemo() {
    const siderItems: NavItemInput[] = [
        { itemKey: 'Home', text: '首页', icon: <IconHome /> },
        { itemKey: 'Histogram', text: '基础数据', icon: <IconHistogram /> },
        { itemKey: 'Live', text: '测试功能', icon: <IconLive /> },
        { itemKey: 'Setting', text: '设置', icon: <IconSetting /> },
    ];

    return <Layout style={{ border: '1px solid var(--lotus-color-border)' }}>
        <Header style={{ backgroundColor: 'var(--lotus-color-bg-1)' }}>
            <div>
                <Nav mode="horizontal" defaultSelectedKeys={['Home']}>
                    <NavHeader logo={<IconLotusLogo />} />
                    <span style={{ color: 'var(--lotus-color-text-2)' }}>
                        <span style={{ marginRight: '24px', color: 'var(--lotus-color-text-0)', fontWeight: 'var(--lotus-font-weight-semibold)' }}>模版推荐</span>
                        <span style={{ marginRight: '24px' }}>所有模版</span>
                        <span>我的模版</span>
                    </span>
                    <NavFooter>
                        <Button theme="borderless" icon={<IconBell />} style={{ color: 'var(--lotus-color-text-2)', marginRight: '12px' }} />
                        <Button theme="borderless" icon={<IconHelpCircle />} style={{ color: 'var(--lotus-color-text-2)', marginRight: '12px' }} />
                        <Avatar color="orange" size="small">YJ</Avatar>
                    </NavFooter>
                </Nav>
            </div>
        </Header>
        <Layout hasSider>
            <Sider style={{ backgroundColor: 'var(--lotus-color-bg-1)' }}>
                <Nav
                    style={{ maxWidth: '220px', height: '100%' }}
                    defaultSelectedKeys={['Home']}
                    items={siderItems}
                    footer={{ collapseButton: true }}
                />
            </Sider>
            <Content style={{ padding: '24px', backgroundColor: 'var(--lotus-color-bg-0)' }}>
                <Breadcrumb
                    style={{ marginBottom: '24px' }}
                    routes={['首页', '当这个页面标题很长时需要省略', '上一页', '详情页']}
                />
                <div style={{ borderRadius: '10px', border: '1px solid var(--lotus-color-border)', height: '200px', padding: '32px' }}>
                    <Skeleton placeholder={<SkeletonParagraph rows={2} />} loading={true}>
                        <p>Hi, Lotus dance dance.</p>
                        <p>Hi, Lotus dance dance.</p>
                    </Skeleton>
                </div>
            </Content>
        </Layout>
        <Footer style={{ display: 'flex', justifyContent: 'space-between', padding: '20px', color: 'var(--lotus-color-text-2)', backgroundColor: 'var(--lotus-color-fill-0)' }}>
            <span style={{ display: 'flex', alignItems: 'center' }}>
                <IconLotusLogo />
                <span style={{ marginLeft: '8px' }}>Copyright © 2026 Lotus. All Rights Reserved.</span>
            </span>
            <span>
                <span style={{ marginRight: '24px' }}>平台客服</span>
                <span>反馈建议</span>
            </span>
        </Footer>
    </Layout>;
}
