import { track, untrack } from 'ripple';
import { ListContext } from './list-context.js';

export type ListItemAlign = 'flex-start' | 'flex-end' | 'center' | 'baseline' | 'stretch';

export interface ListItemProps {
    header?: any;
    main?: any;
    extra?: any;
    children?: any;
    align?: ListItemAlign;
    onClick?: (event: MouseEvent) => void;
    onRightClick?: (event: MouseEvent) => void;
    onMouseEnter?: (event: MouseEvent) => void;
    onMouseLeave?: (event: MouseEvent) => void;
    class?: string;
    style?: Record<string, any>;
}

export function ListItem(&{
    header,
    main,
    extra,
    children,
    align = 'flex-start',
    onClick,
    onRightClick,
    onMouseEnter,
    onMouseLeave,
    class: className,
    style,
}: ListItemProps) @{
    const contextTracked = ListContext.get();
    const hasBody = header !== undefined || main !== undefined;

    function handleClick(event: MouseEvent) {
        const handler = onClick ?? untrack(() => contextTracked)?.value.onClick;
        handler?.(event);
    }

    function handleContextMenu(event: MouseEvent) {
        const handler = onRightClick ?? untrack(() => contextTracked)?.value.onRightClick;
        handler?.(event);
    }

    let &[classes] = track<string>(() => ['lotus-list-item', className ?? ''].filter(Boolean).join(' '));

    <>
        <div
            class={classes}
            style={style}
            onClick={handleClick}
            onContextMenu={handleContextMenu}
            onMouseEnter={onMouseEnter}
            onMouseLeave={onMouseLeave}
        >
            @if (hasBody) {
                <div class="lotus-list-item-body" style={{ alignItems: align }}>
                    @if (header !== undefined) {
                        <div class="lotus-list-item-body-header">{header}</div>
                    }
                    @if (main !== undefined) {
                        <div class="lotus-list-item-body-main">{main}</div>
                    }
                </div>
            }
            {children}
            @if (extra !== undefined) {
                <div class="lotus-list-item-extra">{extra}</div>
            }
        </div>

        <style>
            .lotus-list-item {
                display: flex;
                align-items: center;
                justify-content: space-between;
                width: 100%;
            }

            .lotus-list-item-body {
                display: flex;
                flex-direction: column;
                flex: 1;
                min-width: 0;
            }

            .lotus-list-item-body-header {
                font-weight: 600;
                color: var(--lotus-color-text-0);
            }

            .lotus-list-item-body-main {
                color: var(--lotus-color-text-2);
                margin-top: var(--lotus-spacing-super-tight);
            }

            .lotus-list-item-extra {
                flex: 0 0 auto;
                margin-inline-start: var(--lotus-spacing-base);
            }
        </style>
    </>
}
