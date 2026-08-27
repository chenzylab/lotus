export interface DividerProps {
    children?: any;
    layout?: 'horizontal' | 'vertical';
    align?: 'left' | 'right' | 'center';
    dashed?: boolean;
    margin?: number | string;
    style?: Record<string, any>;
    class?: string;
}

export function Divider(&{
    children,
    layout = 'horizontal',
    align = 'center',
    dashed = false,
    margin,
    style,
    class: className,
}: DividerProps) @{
    const marginValue = typeof margin === 'number' ? `${margin}px` : (margin ?? '');
    const hasText = layout === 'horizontal' && children != null;
    const classes = [
        'lotus-divider',
        `lotus-divider-${layout}`,
        dashed ? 'lotus-divider-dashed' : '',
        hasText ? `lotus-divider-with-text lotus-divider-with-text-${align}` : '',
        className ?? '',
    ]
        .filter(Boolean)
        .join(' ');

    <>
        @if (hasText) {
            <div class={classes} style={{ ...style, '--lotus-divider-margin': marginValue }}>
                <span class="lotus-divider-inner-text">{children}</span>
            </div>
        } @else {
            <div class={classes} style={{ ...style, '--lotus-divider-margin': marginValue }} />
        }

        <style>
            .lotus-divider {
                box-sizing: border-box;
                color: var(--lotus-color-text-1);
            }

            .lotus-divider-horizontal {
                width: 100%;
                display: flex;
                align-items: center;
                border-bottom: 1px solid var(--lotus-color-border);
                margin: var(--lotus-divider-margin, var(--lotus-spacing-base)) 0;
            }

            .lotus-divider-vertical {
                display: inline-block;
                height: 0.9em;
                margin: 0 var(--lotus-divider-margin, var(--lotus-spacing-tight));
                border-inline-start: 1px solid var(--lotus-color-border);
                vertical-align: middle;
            }

            .lotus-divider-dashed {
                border-bottom-style: dashed;
                border-left-style: dashed;
            }

            .lotus-divider-with-text {
                border-bottom: 0;
                white-space: nowrap;
            }

            .lotus-divider-with-text::before,
            .lotus-divider-with-text::after {
                content: '';
                flex: 1;
                border-bottom: 1px solid var(--lotus-color-border);
            }

            .lotus-divider-with-text.lotus-divider-dashed::before,
            .lotus-divider-with-text.lotus-divider-dashed::after {
                border-bottom-style: dashed;
            }

            .lotus-divider-with-text-left::before {
                flex: 0 0 5%;
            }

            .lotus-divider-with-text-right::after {
                flex: 0 0 5%;
            }

            .lotus-divider-inner-text {
                padding: 0 var(--lotus-spacing-base-tight);
                font-weight: var(--lotus-font-weight-bold);
                display: inline-block;
            }
        </style>
    </>
}
