import { track, effect, untrack } from 'ripple';
import { TabsContext } from './tabs-context.js';

export interface TabPaneProps {
    itemKey: string;
    tab?: any;
    icon?: any;
    disabled?: boolean;
    closable?: boolean;
    children?: any;
    class?: string;
    style?: Record<string, any>;
}

/**
 * TabPane：Tabs 的声明式子组件写法，对齐 Semi `<Tabs><TabPane itemKey="1"
 * tab="标题">内容</TabPane></Tabs>` 的 JSX 嵌套语义。mount 时把自己的
 * itemKey/tab/icon/disabled/closable 注册进 TabsContext（对齐 Anchor
 * AnchorLink 的 registerLink 模式——Semi 本体用 React.Children.toArray
 * 从 children 提取 tab 元数据渲染 TabBar，Ripple 无 children 遍历能力，
 * 靠 TabPane 自己注册绕过），unmount 时注销；自己只负责在自己是
 * activeKey 时渲染 children（不像 tabList 数组方案那样把渲染函数交给
 * 父组件持有）。
 */
export function TabPane(&{ itemKey, tab, icon, disabled = false, closable = false, children, class: className, style }: TabPaneProps) @{
    const tabsTracked = TabsContext.get();

    effect(() => {
        untrack(() => tabsTracked?.value.registerPane({ itemKey, tab, icon, disabled, closable }));
        return () => untrack(() => tabsTracked?.value.unregisterPane(itemKey));
    });

    let &[isActive] = track<boolean>(() => tabsTracked?.value.activeKey === itemKey);

    <>
        @if (isActive) {
            <div class={['lotus-tabs-pane-content', className ?? ''].filter(Boolean).join(' ')} style={style} role="tabpanel">
                {children}
            </div>
        }
    </>
}
