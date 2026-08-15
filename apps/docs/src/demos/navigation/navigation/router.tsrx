import { Nav } from '@lotus/ripple';
import type { NavItemInput } from '@lotus/ripple';

/**
 * 演示如何用 renderWrapper 在每个导航项外包裹自定义元素，用于集成路由库的 Link/NavLink
 * 组件。lotus 没有 react-router 这样的具体路由库依赖，这里用普通 `<a>` 模拟"点击后由
 * 路由组件接管跳转"的包裹方式，实际集成时把 `<a>` 换成对应路由库的 Link 组件即可。
 */
export function RouterNavDemo() {
    const routerMap: Record<string, string> = {
        Home: '/',
        About: '/about',
        Dashboard: '/dashboard',
        'Nothing Here': '/nothing-here',
    };

    const items: NavItemInput[] = [
        { itemKey: 'Home', text: 'Home' },
        { itemKey: 'About', text: 'About' },
        {
            text: 'Sub',
            itemKey: 'Sub',
            items: ['Dashboard', 'Nothing Here'],
        },
    ];

    return <div style={{ width: '200px', border: '1px solid var(--lotus-color-border)' }}>
        <Nav
            items={items}
            renderWrapper={({ itemElement, item }) => (
                <a style={{ textDecoration: 'none', color: 'inherit' }} href={routerMap[item.itemKey as string] ?? '#'}>
                    {itemElement}
                </a>
            )}
        />
    </div>;
}
