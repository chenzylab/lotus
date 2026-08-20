export interface ScrollListProps {
    header?: any;
    footer?: any;
    children?: any;
    bodyHeight?: string | number;
    style?: Record<string, any>;
    class?: string;
}

export function ScrollList(&{
    header,
    footer,
    children,
    bodyHeight,
    style,
    class: className,
}: ScrollListProps) @{
    <>
        <div class={['lotus-scroll-list', className ?? ''].filter(Boolean).join(' ')} style={style}>
            @if (header !== undefined) {
                <div class="lotus-scroll-list-header">{header}</div>
            }
            <div class="lotus-scroll-list-body" style={{ ...(bodyHeight !== undefined ? { height: typeof bodyHeight === 'number' ? `${bodyHeight}px` : bodyHeight } : {}) }}>
                {children}
            </div>
            @if (footer !== undefined) {
                <div class="lotus-scroll-list-footer">{footer}</div>
            }
        </div>

        <style>
            .lotus-scroll-list {
                display: flex;
                flex-direction: column;
                border: 1px solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-medium);
                background: var(--lotus-color-bg-1);
                overflow: hidden;
            }

            .lotus-scroll-list-header {
                display: flex;
                border-bottom: 1px solid var(--lotus-color-border);
                flex-shrink: 0;
            }

            .lotus-scroll-list-body {
                position: relative;
                display: flex;
                flex-shrink: 0;
                overflow: hidden;
            }

            .lotus-scroll-list-footer {
                border-top: 1px solid var(--lotus-color-border);
                flex-shrink: 0;
            }
        </style>
    </>
}
