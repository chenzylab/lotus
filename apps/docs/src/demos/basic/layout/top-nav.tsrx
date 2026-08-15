import { Layout, Header, Footer, Content, Nav, NavHeader, NavItem, NavFooter, Button, Breadcrumb, Skeleton, SkeletonParagraph, Avatar } from '@lotus/ripple';
import { IconLotusLogo, IconHome, IconLive, IconSetting, IconBell, IconHelpCircle } from '@lotus/icons';

export function TopNavLayoutDemo() {
    return <Layout style={{ border: '1px solid var(--lotus-color-border)' }}>
        <Header style={{ backgroundColor: 'var(--lotus-color-bg-1)' }}>
            <div>
                <Nav mode="horizontal" defaultSelectedKeys={['Home']}>
                    <NavHeader logo={<IconLotusLogo />} />
                    <NavItem itemKey="Home" text="首页" icon={<IconHome />} />
                    <NavItem itemKey="Live" text="直播" icon={<IconLive />} />
                    <NavItem itemKey="Setting" text="设置" icon={<IconSetting />} />
                    <NavFooter>
                        <Button theme="borderless" icon={<IconBell />} style={{ color: 'var(--lotus-color-text-2)', marginRight: '12px' }} />
                        <Button theme="borderless" icon={<IconHelpCircle />} style={{ color: 'var(--lotus-color-text-2)', marginRight: '12px' }} />
                        <Avatar color="orange" size="small">YJ</Avatar>
                    </NavFooter>
                </Nav>
            </div>
        </Header>
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
