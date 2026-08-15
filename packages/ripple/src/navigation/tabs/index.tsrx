import { track } from 'ripple';
import { TabsFoundation, type TabsState, type TabItemMeta } from '@lotus/foundation/navigation/tabs';

export type TabsType = 'line' | 'card' | 'button';
export type TabsPosition = 'top' | 'left';
export type TabsSize = 'small' | 'medium' | 'large';

export interface TabItem {
    itemKey: string;
    tab?: any;
    disabled?: boolean;
    closable?: boolean;
    icon?: any;
    /** 该面板的内容渲染函数：仅在自己是激活项（或 keepDOM 且曾经激活过）时被调用。 */
    render: () => any;
}

export interface TabsProps {
    tabList: TabItem[];
    activeKey?: string;
    defaultActiveKey?: string;
    type?: TabsType;
    tabPosition?: TabsPosition;
    size?: TabsSize;
    /** 未激活的面板是否仍保留在 DOM 中（默认 true，对齐 Semi 默认值，便于配合 CSS 做切换动画）。 */
    keepDOM?: boolean;
    /** 面板内容是否懒挂载：首次激活前不渲染 render()（默认 false）。 */
    lazyRender?: boolean;
    onChange?: (activeKey: string) => void;
    onTabClick?: (activeKey: string, event: MouseEvent) => void;
    onTabClose?: (itemKey: string) => void;
    style?: Record<string, any>;
    class?: string;
}

function panesFromTabList(tabList: TabItem[]): TabItemMeta[] {
    return tabList.map(({ itemKey, tab, disabled, closable, icon }) => ({ itemKey, tab, disabled, closable, icon }));
}

export function Tabs({
    tabList,
    activeKey: activeKeyProp,
    defaultActiveKey,
    type = 'line',
    tabPosition = 'top',
    size = 'large',
    keepDOM = true,
    lazyRender = false,
    onChange,
    onTabClick,
    onTabClose,
    style,
    class: className,
}: TabsProps) @{
    const isControlled = activeKeyProp !== undefined;
    const initialActiveKey = isControlled
        ? activeKeyProp!
        : (defaultActiveKey ?? TabsFoundation.resolveDefaultActiveKey(panesFromTabList(tabList)));

    let &[state] = track<TabsState>({ activeKey: initialActiveKey, panes: panesFromTabList(tabList) });
    // 曾经激活过的 itemKey 集合，用于 lazyRender：一旦渲染过就常驻，不随切换卸载
    // （对齐 Semi TabPane 的 `_active` 语义——懒挂载但挂载后不再卸载）。
    let &[everActivated] = track<Set<string>>(new Set(initialActiveKey ? [initialActiveKey] : []));

    const foundation = new TabsFoundation({
        getState: () => state,
        setState: (patch: Partial<TabsState>) => { state = { ...state, ...patch }; },
    });

    // 受控模式下，视觉激活项直接跟随外部传入的 activeKey，不依赖内部 state.activeKey
    // （同 Switch/Grid 已验证的受控模式范式：Foundation 受控分支不改写 state）。
    let &[displayActiveKey] = track<string>(() => (isControlled ? activeKeyProp! : state.activeKey));

    let &[classes] = track<string>(() =>
        [
            'lotus-tabs',
            `lotus-tabs-${type}`,
            `lotus-tabs-${tabPosition}`,
            `lotus-tabs-${size}`,
            className ?? '',
        ]
            .filter(Boolean)
            .join(' '),
    );

    const handleTabClick = (itemKey: string, event: MouseEvent) => {
        foundation.handleTabClick(itemKey, isControlled, onChange);
        onTabClick?.(itemKey, event);
        if (!everActivated.has(itemKey)) {
            everActivated = new Set(everActivated).add(itemKey);
        }
    };

    const handleTabClose = (itemKey: string, event: MouseEvent) => {
        event.stopPropagation();
        onTabClose?.(itemKey);
    };

    const handleKeyDown = (itemKey: string, event: KeyboardEvent) => {
        const isVertical = tabPosition === 'left';
        const nextKey = isVertical
            ? (event.key === 'ArrowDown' ? foundation.resolveArrowNavigation(itemKey, 1)
                : event.key === 'ArrowUp' ? foundation.resolveArrowNavigation(itemKey, -1) : null)
            : (event.key === 'ArrowRight' ? foundation.resolveArrowNavigation(itemKey, 1)
                : event.key === 'ArrowLeft' ? foundation.resolveArrowNavigation(itemKey, -1) : null);

        if (nextKey && nextKey !== itemKey) {
            event.preventDefault();
            handleTabClick(nextKey, event as unknown as MouseEvent);
            queueMicrotask(() => {
                document.getElementById(`lotus-tab-${nextKey}`)?.focus();
            });
            return;
        }

        if (event.key === 'Enter' || event.key === ' ') {
            event.preventDefault();
            handleTabClick(itemKey, event as unknown as MouseEvent);
        }
    };

    const shouldRenderPane = (itemKey: string): boolean => {
        if (!lazyRender) return true;
        return everActivated.has(itemKey);
    };

    <>
        <div class={classes} style={style}>
            <div class="lotus-tabs-bar" role="tablist" aria-orientation={tabPosition === 'left' ? 'vertical' : 'horizontal'}>
                @for (const item of tabList; key item.itemKey) {
                    <div
                        id={`lotus-tab-${item.itemKey}`}
                        class={[
                            'lotus-tabs-tab',
                            displayActiveKey === item.itemKey ? 'lotus-tabs-tab-active' : '',
                            item.disabled ? 'lotus-tabs-tab-disabled' : '',
                        ].filter(Boolean).join(' ')}
                        role="tab"
                        aria-selected={displayActiveKey === item.itemKey}
                        aria-disabled={!!item.disabled}
                        aria-controls={`lotus-tabpanel-${item.itemKey}`}
                        tabIndex={displayActiveKey === item.itemKey ? 0 : -1}
                        onClick={(event: MouseEvent) => !item.disabled && handleTabClick(item.itemKey, event)}
                        onKeyDown={(event: KeyboardEvent) => !item.disabled && handleKeyDown(item.itemKey, event)}
                    >
                        @if (item.icon) {
                            <span class="lotus-tabs-tab-icon">{item.icon}</span>
                        }
                        <span class="lotus-tabs-tab-label">{item.tab}</span>
                        @if (item.closable) {
                            <span
                                class="lotus-tabs-tab-close"
                                aria-label="关闭标签页"
                                onClick={(event: MouseEvent) => handleTabClose(item.itemKey, event)}
                            >
                                ×
                            </span>
                        }
                    </div>
                }
            </div>

            <div class="lotus-tabs-content">
                @for (const item of tabList; key item.itemKey) {
                    @if (keepDOM) {
                        <div
                            id={`lotus-tabpanel-${item.itemKey}`}
                            class="lotus-tabs-pane"
                            role="tabpanel"
                            aria-hidden={displayActiveKey !== item.itemKey}
                            style={{ display: displayActiveKey === item.itemKey ? '' : 'none' }}
                        >
                            @if (shouldRenderPane(item.itemKey)) {
                                <{item.render} />
                            }
                        </div>
                    } @else {
                        @if (displayActiveKey === item.itemKey) {
                            <div id={`lotus-tabpanel-${item.itemKey}`} class="lotus-tabs-pane" role="tabpanel">
                                <{item.render} />
                            </div>
                        }
                    }
                }
            </div>
        </div>

        <style>
            .lotus-tabs {
                display: flex;
                box-sizing: border-box;
            }

            .lotus-tabs-top {
                flex-direction: column;
            }

            .lotus-tabs-left {
                flex-direction: row;
            }

            .lotus-tabs-bar {
                display: flex;
                gap: var(--lotus-spacing-base);
            }

            .lotus-tabs-top .lotus-tabs-bar {
                flex-direction: row;
                border-bottom: 1px solid var(--lotus-color-border);
            }

            .lotus-tabs-left .lotus-tabs-bar {
                flex-direction: column;
                border-right: 1px solid var(--lotus-color-border);
                padding-right: var(--lotus-spacing-base);
                margin-right: var(--lotus-spacing-base);
            }

            .lotus-tabs-tab {
                display: inline-flex;
                align-items: center;
                gap: 4px;
                box-sizing: border-box;
                padding: var(--lotus-spacing-base-tight) var(--lotus-spacing-tight);
                color: var(--lotus-color-text-1);
                font-size: var(--lotus-font-body-size);
                cursor: pointer;
                user-select: none;
                white-space: nowrap;
            }

            .lotus-tabs-small .lotus-tabs-tab {
                padding: var(--lotus-spacing-tight) var(--lotus-spacing-tight);
                font-size: var(--lotus-font-label-size);
            }

            .lotus-tabs-tab:hover:not(.lotus-tabs-tab-disabled) {
                color: var(--lotus-color-text-0);
            }

            .lotus-tabs-tab-disabled {
                color: var(--lotus-color-disabled-text);
                cursor: not-allowed;
            }

            .lotus-tabs-line .lotus-tabs-tab-active {
                color: var(--lotus-color-primary);
                font-weight: var(--lotus-font-weight-semibold);
            }

            .lotus-tabs-line.lotus-tabs-top .lotus-tabs-tab-active {
                box-shadow: inset 0 -2px 0 0 var(--lotus-color-primary);
            }

            .lotus-tabs-line.lotus-tabs-left .lotus-tabs-tab-active {
                box-shadow: inset 2px 0 0 0 var(--lotus-color-primary);
            }

            .lotus-tabs-card .lotus-tabs-tab {
                border: 1px solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-small) var(--lotus-border-radius-small) 0 0;
                background: var(--lotus-color-bg-2);
            }

            .lotus-tabs-card .lotus-tabs-tab-active {
                background: var(--lotus-color-bg-1);
                border-bottom-color: transparent;
                color: var(--lotus-color-text-0);
            }

            .lotus-tabs-button .lotus-tabs-tab {
                border-radius: var(--lotus-border-radius-full);
                background: transparent;
            }

            .lotus-tabs-button .lotus-tabs-tab-active {
                background: var(--lotus-color-fill-1);
                color: var(--lotus-color-text-0);
            }

            .lotus-tabs-tab-close {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                margin-left: 2px;
                opacity: 0.6;
                line-height: 1;
            }

            .lotus-tabs-tab-close:hover {
                opacity: 1;
            }

            .lotus-tabs-content {
                flex: 1;
                min-width: 0;
            }
        </style>
    </>
}
