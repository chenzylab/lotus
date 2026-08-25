export interface SidebarOption {
    icon?: any;
    name?: string;
    key: string;
}

export interface OptionsProps {
    options?: SidebarOption[];
    activeKey?: string;
    onActiveOptionChange?: (event: MouseEvent, key: string) => void;
    renderOptionItem?: (option: SidebarOption, onChange: (key: string) => void) => any;
    class?: string;
    style?: Record<string, any>;
}

/**
 * Sidebar.Options：mode='main' 时的选项列表，纯展示组件——选中态完全由
 * `activeKey` 受控（对齐 Semi），不需要内部状态机。
 */
export function Options(&{
    options,
    activeKey,
    onActiveOptionChange,
    renderOptionItem,
    class: className,
    style,
}: OptionsProps) @{
    function handleChange(event: MouseEvent, key: string) {
        onActiveOptionChange?.(event, key);
    }

    <>
        <div class={['lotus-sidebar-options', className ?? ''].filter(Boolean).join(' ')} style={style}>
            @for (const option of options ?? []; key option.key) {
                @if (renderOptionItem) {
                    <>{renderOptionItem(option, (key: string) => onActiveOptionChange?.(new MouseEvent('click'), key))}</>
                } @else {
                    <div
                        class={['lotus-sidebar-option-item', option.key === activeKey ? 'lotus-sidebar-option-item-active' : ''].filter(Boolean).join(' ')}
                        onClick={(event: MouseEvent) => handleChange(event, option.key)}
                    >
                        @if (option.icon) {
                            <span class="lotus-sidebar-option-icon">{option.icon}</span>
                        }
                        <span class="lotus-sidebar-option-name">{option.name ?? option.key}</span>
                    </div>
                }
            }
        </div>

        <style>
            .lotus-sidebar-options {
                display: flex;
                flex-direction: column;
                gap: 4px;
            }

            .lotus-sidebar-option-item {
                display: flex;
                align-items: center;
                gap: 8px;
                padding: 8px 12px;
                border-radius: var(--lotus-border-radius-small);
                cursor: pointer;
                color: var(--lotus-color-text-1);
            }

            .lotus-sidebar-option-item:hover {
                background: var(--lotus-color-fill-0);
            }

            .lotus-sidebar-option-item-active {
                background: var(--lotus-color-fill-1);
                color: var(--lotus-color-primary);
            }

            .lotus-sidebar-option-icon {
                display: inline-flex;
                align-items: center;
                flex-shrink: 0;
            }

            .lotus-sidebar-option-name {
                font-size: 14px;
            }
        </style>
    </>
}
