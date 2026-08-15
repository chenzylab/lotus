import { Nav } from '@lotus/ripple';
import type { NavItemInput } from '@lotus/ripple';
import { IconLotusLogo } from '@lotus/icons';
import { IconAvatar, IconDescriptions, IconTree } from '@lotus/icons-lab';

export function BasicNavDemo() {
    const items: NavItemInput[] = [
        { itemKey: 'user', text: '用户管理', icon: <IconAvatar /> },
        { itemKey: 'union', text: '活动管理', icon: <IconDescriptions /> },
        {
            text: '任务平台',
            icon: <IconTree />,
            itemKey: 'job',
            items: ['任务管理', '用户任务查询'],
        },
    ];

    return <div style={{ width: '260px', border: '1px solid var(--lotus-color-border)' }}>
        <Nav
            bodyStyle={{ height: '320px' }}
            items={items}
            header={{ logo: <IconLotusLogo />, text: 'Lotus 运营后台' }}
            footer={{ collapseButton: true }}
            onSelect={(data) => console.log('trigger onSelect: ', data)}
            onClick={(data) => console.log('trigger onClick: ', data)}
        />
    </div>;
}
