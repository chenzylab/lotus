import { track } from 'ripple';

export type DropdownItemType = 'primary' | 'secondary' | 'tertiary' | 'warning' | 'danger';

export interface DropdownItemProps {
    children?: any;
    active?: boolean;
    disabled?: boolean;
    icon?: any;
    type?: DropdownItemType;
    style?: Record<string, any>;
    class?: string;
    onClick?: (event: MouseEvent) => void;
    onMouseEnter?: (event: MouseEvent) => void;
    onMouseLeave?: (event: MouseEvent) => void;
    onContextMenu?: (event: MouseEvent) => void;
}

export function DropdownItem(&{
    children,
    active = false,
    disabled = false,
    icon,
    type = 'tertiary',
    style,
    class: className,
    onClick,
    onMouseEnter,
    onMouseLeave,
    onContextMenu,
}: DropdownItemProps) @{
    const handleClick = (event: MouseEvent) => {
        if (disabled) return;
        onClick?.(event);
    };

    let &[classes] = track(() =>
        [
            'lotus-dropdown-item',
            `lotus-dropdown-item-${type}`,
            active ? 'lotus-dropdown-item-active' : '',
            disabled ? 'lotus-dropdown-item-disabled' : '',
            className ?? '',
        ]
            .filter(Boolean)
            .join(' '),
    );

    <>
        <li
            role="menuitem"
            tabIndex={disabled ? -1 : 0}
            aria-disabled={disabled}
            class={classes}
            style={style}
            onClick={handleClick}
            onMouseEnter={onMouseEnter}
            onMouseLeave={onMouseLeave}
            onContextMenu={onContextMenu}
        >
            @if (icon != null) {
                <span class="lotus-dropdown-item-icon">{icon}</span>
            }
            <span class="lotus-dropdown-item-content">{children}</span>
        </li>

        <style>
            .lotus-dropdown-item {
                display: flex;
                align-items: center;
                height: 32px;
                padding: 0 12px;
                box-sizing: border-box;
                border-radius: var(--lotus-border-radius-small);
                cursor: pointer;
                color: var(--lotus-color-text-0);
                white-space: nowrap;
                font-size: var(--lotus-font-body-size);
            }

            .lotus-dropdown-item:hover {
                background: var(--lotus-color-fill-0);
            }

            .lotus-dropdown-item-icon {
                display: inline-flex;
                align-items: center;
                margin-inline-end: 8px;
            }

            .lotus-dropdown-item-active {
                background: var(--lotus-color-fill-0);
                font-weight: var(--lotus-font-weight-semibold);
            }

            .lotus-dropdown-item-disabled {
                color: var(--lotus-color-disabled-text);
                cursor: not-allowed;
                pointer-events: none;
            }

            .lotus-dropdown-item-secondary {
                color: var(--lotus-color-primary);
            }

            .lotus-dropdown-item-warning {
                color: var(--lotus-color-warning);
            }

            .lotus-dropdown-item-danger {
                color: var(--lotus-color-danger);
            }
        </style>
    </>
}
