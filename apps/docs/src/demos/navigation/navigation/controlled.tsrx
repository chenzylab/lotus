import { Nav } from '@lotus/ripple';
import { track } from 'ripple';
import type { NavItemInput, ItemKey } from '@lotus/ripple';
import { IconLotusLogo } from '@lotus/icons';
import { IconBadge, IconBanner, IconForm, IconTree } from '@lotus/icons-lab';

export function ControlledNavDemo() @{
    let &[openKeys] = track<ItemKey[]>(['union-management', 'job']);
    let &[selectedKeys] = track<ItemKey[]>(['公告设置']);
    let &[isCollapsed] = track<boolean>(true);

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

    <div style={{ width: '260px', border: '1px solid var(--lotus-color-border)' }}>
        <Nav
            isCollapsed={isCollapsed}
            openKeys={openKeys}
            selectedKeys={selectedKeys}
            bodyStyle={{ height: '260px' }}
            items={items}
            header={{ logo: <IconLotusLogo />, text: 'Lotus 运营后台' }}
            footer={{ collapseButton: true }}
            onCollapseChange={(collapsed) => { isCollapsed = collapsed; }}
            onOpenChange={(data) => { openKeys = [...data.openKeys]; }}
            onSelect={(data) => { selectedKeys = [...data.selectedKeys]; }}
        />
    </div>
}
