import { Nav } from '@lotus/ripple';
import type { NavItemInput } from '@lotus/ripple';
import { IconLotusLogo } from '@lotus/icons';
import { IconBadge, IconBanner, IconForm, IconTabs } from '@lotus/icons-lab';

export function IndentNavDemo() {
    const items: NavItemInput[] = [
        { itemKey: 'user', text: '用户管理', icon: <IconBadge /> },
        {
            text: '任务平台',
            icon: <IconBanner />,
            itemKey: 'job',
            items: [
                '任务管理',
                {
                    text: '任务1',
                    icon: <IconForm />,
                    itemKey: 'mission1',
                    items: [
                        '任务2',
                        {
                            text: '任务3拆解',
                            icon: <IconTabs />,
                            itemKey: 'mission3',
                            items: ['子任务1', '子任务2'],
                        },
                    ],
                },
            ],
        },
    ];

    return <div style={{ width: '260px', border: '1px solid var(--lotus-color-border)' }}>
        <Nav
            limitIndent={false}
            defaultOpenKeys={['job', 'mission1']}
            bodyStyle={{ height: '260px' }}
            items={items}
            onSelect={(key) => console.log(key)}
            header={{ logo: <IconLotusLogo />, text: 'Lotus 运营后台' }}
            footer={{ collapseButton: true }}
        />
    </div>;
}
