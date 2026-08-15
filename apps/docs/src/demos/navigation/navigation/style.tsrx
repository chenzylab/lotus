import { Nav } from '@lotus/ripple';
import type { NavItemInput } from '@lotus/ripple';
import { IconLotusLogo } from '@lotus/icons';
import { IconBadge, IconBanner, IconForm, IconNavigation, IconNotification, IconSteps, IconTabs, IconTree, IconTreeSelect } from '@lotus/icons-lab';

export function StyleNavDemo() {
    const items: NavItemInput[] = [
        { itemKey: 'user', text: '用户管理', icon: <IconBadge /> },
        { itemKey: '2', text: '订单管理', icon: <IconBanner /> },
        { itemKey: '3', text: '资源管理', icon: <IconTreeSelect /> },
        {
            text: '任务平台',
            icon: <IconForm />,
            itemKey: '4',
            items: ['任务管理', '用户任务查询'],
        },
        { itemKey: '5', text: '推送通知', icon: <IconNotification /> },
        { itemKey: '6', text: '任务', icon: <IconSteps /> },
        { itemKey: '7', text: '活动管理', icon: <IconTree /> },
        { itemKey: '8', text: '内容工具', icon: <IconTabs /> },
        { itemKey: '9', text: '快捷导航', icon: <IconNavigation /> },
    ];

    return <div style={{ width: '260px' }}>
        <Nav
            style={{ height: '400px', border: '1px solid var(--lotus-color-border)' }}
            bodyStyle={{ height: '260px' }}
            items={items}
            onSelect={(key) => console.log(key)}
            header={{ logo: <IconLotusLogo />, text: 'Lotus 运营后台' }}
            footer={{ collapseButton: true }}
        />
    </div>;
}
