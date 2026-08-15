import { Nav, NavHeader, NavItem, NavSub, NavFooter } from '@lotus/ripple';
import { IconLotusLogo } from '@lotus/icons';
import { IconBadge, IconForm, IconTree } from '@lotus/icons-lab';

/**
 * Semi 官方此小节演示 `<Nav.Header>`/`<Nav.Item>`/`<Nav.Sub>`/`<Nav.Footer>` 作为
 * Nav 的 JSX children 组合使用。lotus 版本用独立命名导出的 `NavHeader`/`NavItem`/
 * `NavSub`/`NavFooter` 组件替代——Ripple 没有 children 反射能力，无法在运行时给
 * `Nav` 函数挂载 `Header`/`Item`/`Sub`/`Footer` 静态属性，这是 Ripple 约束下的诚实
 * 设计取舍。这几个子组件通过 Context 与外层 `<Nav>` 通信，必须渲染在 `<Nav>` 内部，
 * 不能独立使用。
 */
export function JsxNavDemo() {
    return <div style={{ width: '260px', border: '1px solid var(--lotus-color-border)' }}>
        <Nav
            bodyStyle={{ height: '260px' }}
            defaultOpenKeys={['user', 'union-management']}
            onSelect={(data) => console.log('trigger onSelect: ', data)}
            onClick={(data) => console.log('trigger onClick: ', data)}
        >
            <NavHeader logo={<IconLotusLogo />} text="Lotus 运营后台" />
            <NavItem itemKey="union" text="活动管理" icon={<IconForm />} />
            <NavSub itemKey="user" text="用户管理" icon={<IconBadge />}>
                <NavItem itemKey="active" text="活跃用户" />
                <NavItem itemKey="negative" text="非活跃用户" />
            </NavSub>
            <NavSub itemKey="union-management" text="任务管理" icon={<IconTree />}>
                <NavItem itemKey="notice" text="任务设置" />
                <NavItem itemKey="query" text="任务查询" />
                <NavItem itemKey="info" text="信息录入" />
            </NavSub>
            <NavFooter collapseButton />
        </Nav>
    </div>;
}
