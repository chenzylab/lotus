export interface DropdownMenuProps {
    children?: any;
    style?: Record<string, any>;
    class?: string;
}

export function DropdownMenu(&{ children, style, class: className }: DropdownMenuProps) @{
    <>
        <ul class={['lotus-dropdown-menu', className ?? ''].filter(Boolean).join(' ')} style={style} role="menu" aria-orientation="vertical">
            {children}
        </ul>

        <style>
            .lotus-dropdown-menu {
                list-style: none;
                margin: 0;
                padding: 4px;
                min-width: 120px;
            }
        </style>
    </>
}
