import { Nav } from '@lotus/ripple';
import type { NavItemInput } from '@lotus/ripple';
import { IconLotusLogo } from '@lotus/icons';
import { IconBadge, IconBanner, IconForm } from '@lotus/icons-lab';

export function ToggleIconPositionNavDemo() {
    const items: NavItemInput[] = [
        { itemKey: 'user', text: '用户管理', icon: <IconBadge /> },
        { itemKey: 'union', text: '活动管理', icon: <IconBanner /> },
        {
            text: '任务平台',
            icon: <IconForm />,
            itemKey: 'job',
            items: ['任务管理', '用户任务查询'],
        },
    ];

    return <div style={{ width: '260px', border: '1px solid var(--lotus-color-border)' }}>
        <Nav
            toggleIconPosition="left"
            defaultOpenKeys={['job']}
            bodyStyle={{ height: '260px' }}
            items={items}
            onSelect={(key) => console.log(key)}
            header={{ logo: <IconLotusLogo />, text: 'Lotus 运营后台' }}
            footer={{ collapseButton: true }}
        />
    </div>;
}
