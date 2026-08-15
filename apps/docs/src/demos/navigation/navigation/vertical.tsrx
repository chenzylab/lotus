import { Nav } from '@lotus/ripple';
import type { NavItemInput } from '@lotus/ripple';
import { IconLotusLogo } from '@lotus/icons';
import { IconBadge, IconBanner, IconForm, IconTreeSelect } from '@lotus/icons-lab';

export function VerticalNavDemo() {
    const items: NavItemInput[] = [
        { itemKey: 'user', text: '用户管理', icon: <IconBadge /> },
        { itemKey: 'union', text: '活动管理', icon: <IconTreeSelect /> },
        {
            itemKey: 'union-management',
            text: '任务管理',
            icon: <IconForm />,
            items: ['任务设置', '任务查询', '信息录入'],
        },
        {
            text: '公告管理',
            icon: <IconBanner />,
            itemKey: 'job',
            items: ['推送管理', '已推送查询'],
        },
    ];

    return <div style={{ width: '100%' }}>
        <div style={{ width: '260px', border: '1px solid var(--lotus-color-border)' }}>
            <Nav
                bodyStyle={{ height: '300px' }}
                items={items}
                onSelect={(key) => console.log(key)}
                header={{ logo: <IconLotusLogo />, text: 'Lotus 运营后台' }}
                footer={{ collapseButton: true }}
            />
        </div>
    </div>;
}
