import { Nav } from '@lotus/ripple';
import type { NavItemInput } from '@lotus/ripple';
import { IconLotusLogo } from '@lotus/icons';
import { IconBadge, IconBanner, IconForm, IconTree } from '@lotus/icons-lab';

export function UncontrolledNavDemo() {
    const items: NavItemInput[] = [
        { itemKey: 'user', text: '用户管理', icon: <IconBadge /> },
        { itemKey: 'union', text: '活动管理', icon: <IconBanner /> },
        {
            itemKey: 'union-management',
            text: '任务管理',
            icon: <IconForm />,
            items: ['公告设置', '任务查询', '信息录入'],
        },
        {
            text: '任务平台',
            icon: <IconTree />,
            itemKey: 'job',
            items: ['任务管理', '用户任务查询'],
        },
    ];

    return <div style={{ width: '260px', border: '1px solid var(--lotus-color-border)' }}>
        <Nav
            defaultOpenKeys={['job']}
            defaultSelectedKeys={['信息录入']}
            defaultIsCollapsed={true}
            bodyStyle={{ height: '260px' }}
            items={items}
            header={{ logo: <IconLotusLogo />, text: 'Lotus 运营后台' }}
            footer={{ collapseButton: true }}
        />
    </div>;
}
