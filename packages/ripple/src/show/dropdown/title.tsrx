export interface DropdownTitleProps {
    children?: any;
    style?: Record<string, any>;
    class?: string;
}

export function DropdownTitle(&{ children, style, class: className }: DropdownTitleProps) @{
    <>
        <li class={['lotus-dropdown-title', className ?? ''].filter(Boolean).join(' ')} style={style} role="presentation">
            {children}
        </li>

        <style>
            .lotus-dropdown-title {
                padding: 6px 12px;
                font-size: var(--lotus-font-label-size);
                color: var(--lotus-color-text-2);
                white-space: nowrap;
            }
        </style>
    </>
}
