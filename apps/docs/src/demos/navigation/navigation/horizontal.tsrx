import { Nav, Avatar, Dropdown, DropdownMenu, DropdownItem } from '@lotus/ripple';
import type { NavItemInput } from '@lotus/ripple';
import { IconLotusLogo } from '@lotus/icons';
import { IconBadge, IconBreadcrumb, IconSteps, IconTreeSelect } from '@lotus/icons-lab';

export function HorizontalNavDemo() {
    const items: NavItemInput[] = [
        { itemKey: 'user', text: '用户管理', icon: <IconBadge /> },
        { itemKey: 'union', text: '活动管理', icon: <IconTreeSelect /> },
        {
            itemKey: 'approve-management',
            text: '审批管理',
            icon: <IconBreadcrumb />,
            items: [
                '入驻审核',
                {
                    itemKey: 'operation-management',
                    text: '运营管理',
                    items: ['人员管理', '人员变更'],
                },
            ],
        },
        {
            text: '任务平台',
            icon: <IconSteps />,
            itemKey: 'job',
            items: ['任务管理', '用户任务查询'],
        },
    ];

    return <div style={{ width: '100%' }}>
        <Nav
            mode="horizontal"
            items={items}
            onSelect={(key) => console.log(key)}
            header={{ logo: <IconLotusLogo />, text: 'Lotus 运营后台' }}
            footer={{
                children: (
                    <Dropdown
                        position="bottomRight"
                        render={
                            <DropdownMenu>
                                <DropdownItem>详情</DropdownItem>
                                <DropdownItem>退出</DropdownItem>
                            </DropdownMenu>
                        }
                    >
                        <Avatar size="small" color="light-blue" style={{ margin: '4px' }}>LU</Avatar>
                        <span>Lotus User</span>
                    </Dropdown>
                ),
            }}
        />
    </div>;
}
