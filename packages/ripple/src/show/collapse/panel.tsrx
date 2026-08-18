import { track, untrack } from 'ripple';
import { IconChevronDown, IconChevronUp } from '@lotus/icons';
import { CollapseContext } from './collapse-context.js';

export interface CollapsePanelProps {
    itemKey: string;
    header?: any;
    extra?: any;
    children?: any;
    showArrow?: boolean;
    disabled?: boolean;
    class?: string;
    style?: Record<string, any>;
}

export function CollapsePanel(&{
    itemKey,
    header,
    extra,
    children,
    showArrow = true,
    disabled = false,
    class: className,
    style,
}: CollapsePanelProps) @{
    const contextTracked = CollapseContext.get();

    let &[activeKeys] = track(() => contextTracked?.value.activeKeys ?? new Set<string>());
    let &[clickHeaderToExpand] = track(() => contextTracked?.value.clickHeaderToExpand ?? true);
    let &[expandIconPosition] = track(() => contextTracked?.value.expandIconPosition ?? 'right');

    let &[isActive] = track<boolean>(() => activeKeys.has(itemKey));
    const hasChildren = children !== undefined;
    const isHeaderString = typeof header === 'string';

    function handleHeaderClick(event: MouseEvent) {
        if (disabled || !hasChildren) return;
        if (!untrack(() => clickHeaderToExpand)) return;
        untrack(() => contextTracked)?.value.onToggle(itemKey, event);
    }

    function handleArrowClick(event: MouseEvent) {
        if (disabled || !hasChildren) return;
        event.stopPropagation();
        untrack(() => contextTracked)?.value.onToggle(itemKey, event);
    }

    let &[panelClasses] = track<string>(() =>
        [
            'lotus-collapse-panel',
            isActive ? 'lotus-collapse-panel-active' : '',
            disabled ? 'lotus-collapse-panel-disabled' : '',
            className ?? '',
        ].filter(Boolean).join(' '),
    );

    let &[headerClasses] = track<string>(() =>
        [
            'lotus-collapse-header',
            `lotus-collapse-header-icon-${expandIconPosition}`,
        ].filter(Boolean).join(' '),
    );

    <>
        <div class={panelClasses} style={style}>
            <div
                class={headerClasses}
                role="button"
                tabindex={disabled ? -1 : 0}
                aria-expanded={isActive}
                aria-disabled={disabled}
                onClick={handleHeaderClick}
            >
                @if (showArrow && expandIconPosition === 'left') {
                    <span class="lotus-collapse-arrow" aria-hidden="true" onClick={handleArrowClick}>
                        @if (isActive) { <IconChevronUp /> }
                        @if (!isActive) { <IconChevronDown /> }
                    </span>
                }
                <div class="lotus-collapse-header-main">
                    @if (isHeaderString) {
                        <span class="lotus-collapse-header-title">{header}</span>
                    }
                    @if (!isHeaderString) {
                        <>{header}</>
                    }
                    @if (isHeaderString && extra !== undefined) {
                        <span class="lotus-collapse-header-extra">{extra}</span>
                    }
                </div>
                @if (showArrow && expandIconPosition === 'right') {
                    <span class="lotus-collapse-arrow" aria-hidden="true" onClick={handleArrowClick}>
                        @if (isActive) { <IconChevronUp /> }
                        @if (!isActive) { <IconChevronDown /> }
                    </span>
                }
            </div>

            <div class={['lotus-collapse-content', isActive ? 'lotus-collapse-content-active' : ''].filter(Boolean).join(' ')} aria-hidden={!isActive}>
                <div class="lotus-collapse-content-inner">
                    {children}
                </div>
            </div>
        </div>

        <style>
            .lotus-collapse-panel {
                border-bottom: 1px solid var(--lotus-color-border);
            }

            .lotus-collapse-header {
                display: flex;
                align-items: center;
                gap: var(--lotus-spacing-tight);
                padding: var(--lotus-spacing-base) 0;
                cursor: pointer;
                user-select: none;
            }

            .lotus-collapse-panel-disabled .lotus-collapse-header {
                cursor: not-allowed;
                color: var(--lotus-color-text-3);
            }

            .lotus-collapse-header-icon-left {
                flex-direction: row;
            }

            .lotus-collapse-header-main {
                flex: 1;
                min-width: 0;
                display: flex;
                align-items: center;
                justify-content: space-between;
            }

            .lotus-collapse-header-title {
                font-size: var(--lotus-font-body-size);
                font-weight: 600;
                color: var(--lotus-color-text-0);
            }

            .lotus-collapse-arrow {
                flex-shrink: 0;
                display: flex;
                align-items: center;
                color: var(--lotus-color-text-2);
                transition: transform 0.2s ease;
            }

            .lotus-collapse-content {
                max-height: 0;
                overflow: hidden;
                transition: max-height 0.25s ease;
            }

            .lotus-collapse-content-active {
                max-height: 2000px;
            }

            .lotus-collapse-content-inner {
                padding-bottom: var(--lotus-spacing-base);
                color: var(--lotus-color-text-0);
                font-size: var(--lotus-font-body-size);
            }
        </style>
    </>
}
