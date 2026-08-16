export interface DropdownDividerProps {
    style?: Record<string, any>;
    class?: string;
}

export function DropdownDivider(&{ style, class: className }: DropdownDividerProps) @{
    <>
        <li class={['lotus-dropdown-divider', className ?? ''].filter(Boolean).join(' ')} style={style} role="separator" />

        <style>
            .lotus-dropdown-divider {
                height: 1px;
                margin: 4px 0;
                background: var(--lotus-color-border);
            }
        </style>
    </>
}
