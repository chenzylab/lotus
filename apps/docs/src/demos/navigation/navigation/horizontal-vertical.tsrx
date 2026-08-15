import { Nav, Avatar, Dropdown, DropdownMenu, DropdownItem, Layout, Header, Footer, Sider, Content, Breadcrumb, Skeleton, SkeletonParagraph } from '@lotus/ripple';
import type { NavItemInput } from '@lotus/ripple';
import { IconLotusLogo } from '@lotus/icons';
import { IconBadge, IconBreadcrumb, IconSteps, IconTreeSelect } from '@lotus/icons-lab';

function TopNav() {
    const items: NavItemInput[] = [
        { itemKey: 'user', text: '用户管理', icon: <IconBadge /> },
        { itemKey: 'union', text: '活动管理', icon: <IconTreeSelect /> },
        {
            itemKey: 'approve-management',
            text: '审批管理',
            icon: <IconBreadcrumb />,
            items: ['入驻审核', { itemKey: 'operation-management', text: '运营管理', items: ['人员管理', '人员变更'] }],
        },
        { text: '任务平台', icon: <IconSteps />, itemKey: 'job', items: ['任务管理', '用户任务查询'] },
    ];

    return <Nav
        mode="horizontal"
        items={items}
        header={{ logo: <IconLotusLogo />, text: 'Lotus 运营后台' }}
        footer={{
            children: (
                <Dropdown
                    position="bottomRight"
                    render={<DropdownMenu><DropdownItem>详情</DropdownItem><DropdownItem>退出</DropdownItem></DropdownMenu>}
                >
                    <Avatar size="small" color="light-blue" style={{ margin: '4px' }}>LU</Avatar>
                    <span>Lotus User</span>
                </Dropdown>
            ),
        }}
    />;
}

function LeftNav() {
    const items: NavItemInput[] = [
        {
            itemKey: 'approve-management',
            text: '审批管理',
            icon: <IconBreadcrumb />,
            items: ['入驻审核', { itemKey: 'operation-management', text: '运营管理', items: ['人员管理', '人员变更'] }],
        },
        { text: '任务平台', icon: <IconSteps />, itemKey: 'job', items: ['任务管理', '用户任务查询'] },
        { itemKey: 'user', text: '用户管理', icon: <IconBadge /> },
        { itemKey: 'union', text: '活动管理', icon: <IconTreeSelect /> },
    ];

    return <Nav style={{ maxWidth: '220px', height: '100%' }} defaultSelectedKeys={['user']} items={items} footer={{ collapseButton: true }} />;
}

function BottomFooterContent() {
    return <>
        <span style={{ display: 'flex', alignItems: 'center' }}>
            <IconLotusLogo />
            <span style={{ marginLeft: '8px' }}>Copyright © 2026 Lotus. All Rights Reserved.</span>
        </span>
        <span>
            <span style={{ marginRight: '24px' }}>平台客服</span>
            <span>反馈建议</span>
        </span>
    </>;
}

export function HorizontalVerticalNavDemo() {
    return <Layout style={{ border: '1px solid var(--lotus-color-border)' }}>
        <Header style={{ backgroundColor: 'var(--lotus-color-bg-1)' }}>
            <TopNav />
        </Header>
        <Layout hasSider>
            <Sider style={{ backgroundColor: 'var(--lotus-color-bg-1)' }}>
                <LeftNav />
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
            <BottomFooterContent />
        </Footer>
    </Layout>;
}
