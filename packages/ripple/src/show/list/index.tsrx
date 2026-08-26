import { track } from 'ripple';
import { Row, Col, type Gutter } from '../../basic/grid/index.tsrx';
import { Spin } from '../../feedback/spin/index.tsrx';
import { ListContext, type ListContextValue } from './list-context.js';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export type ListLayout = 'vertical' | 'horizontal';
export type ListSize = 'small' | 'default' | 'large';

export interface ListGrid {
    span?: number;
    gutter?: Gutter | [Gutter, Gutter];
    xs?: number;
    sm?: number;
    md?: number;
    lg?: number;
    xl?: number;
    xxl?: number;
}

export interface ListProps<T = any> {
    children?: any;
    dataSource?: T[];
    renderItem?: (item: T, index: number) => any;
    bordered?: boolean;
    header?: any;
    footer?: any;
    layout?: ListLayout;
    size?: ListSize;
    split?: boolean;
    emptyContent?: any;
    grid?: ListGrid;
    loading?: boolean;
    loadMore?: any;
    onClick?: (event: MouseEvent) => void;
    onRightClick?: (event: MouseEvent) => void;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

export function List(&{
    children,
    dataSource,
    renderItem,
    bordered = false,
    header,
    footer,
    layout = 'vertical',
    size = 'default',
    split = true,
    emptyContent,
    grid,
    loading = false,
    loadMore,
    onClick,
    onRightClick,
    style,
    class: className,
    'aria-label': ariaLabel,
}: ListProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);
    let &[dataItems] = track<any[]>(() => (dataSource && dataSource.length && renderItem ? dataSource : []));
    let &[isEmpty] = track<boolean>(() => dataItems.length === 0 && children === undefined);
    const isGrid = grid !== undefined;

    let &[classes] = track<string>(() =>
        [
            'lotus-list',
            bordered ? 'lotus-list-bordered' : '',
            `lotus-list-${layout}`,
            `lotus-list-${size}`,
            split ? 'lotus-list-split' : '',
            className ?? '',
        ].filter(Boolean).join(' '),
    );

    let &[, contextTracked] = track<ListContextValue>(() => ({
        grid,
        onClick,
        onRightClick,
    }));
    ListContext.set(contextTracked);

    <>
        <div class={classes} style={style} aria-label={ariaLabel}>
            @if (header !== undefined) {
                <div class="lotus-list-header">{header}</div>
            }

            <Spin spinning={loading} size="large">
                @if (isEmpty) {
                    <div class="lotus-list-empty">{emptyContent ?? locale.List.emptyContent}</div>
                }
                @if (!isEmpty && isGrid) {
                    <Row gutter={grid!.gutter} class="lotus-list-items-grid" style={{}}>
                        @for (const item of dataItems; index i) {
                            <Col span={grid!.span} xs={grid!.xs} sm={grid!.sm} md={grid!.md} lg={grid!.lg} xl={grid!.xl} xxl={grid!.xxl}>
                                {renderItem!(item, i)}
                            </Col>
                        }
                        {children}
                    </Row>
                }
                @if (!isEmpty && !isGrid) {
                    <ul class="lotus-list-items" role="list">
                        @for (const item of dataItems; index i) {
                            <li class="lotus-list-item-wrapper" role="listitem">{renderItem!(item, i)}</li>
                        }
                        {children}
                    </ul>
                }
            </Spin>

            @if (loadMore !== undefined) {
                <div class="lotus-list-load-more">{loadMore}</div>
            }

            @if (footer !== undefined) {
                <div class="lotus-list-footer">{footer}</div>
            }
        </div>

        <style>
            .lotus-list {
                display: flex;
                flex-direction: column;
                background: var(--lotus-color-bg-1);
            }

            .lotus-list-bordered {
                border: 1px solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-medium);
            }

            .lotus-list-header,
            .lotus-list-footer {
                padding: var(--lotus-spacing-base) var(--lotus-spacing-base-loose);
                color: var(--lotus-color-text-0);
                font-weight: 600;
            }

            .lotus-list-bordered .lotus-list-header {
                border-bottom: 1px solid var(--lotus-color-border);
            }

            .lotus-list-bordered .lotus-list-footer {
                border-top: 1px solid var(--lotus-color-border);
            }

            .lotus-list-items {
                display: flex;
                flex-direction: column;
                margin: 0;
                padding: 0;
                list-style: none;
            }

            .lotus-list-horizontal .lotus-list-items {
                flex-direction: row;
                flex-wrap: wrap;
            }

            .lotus-list-items-grid {
                margin: 0 !important;
            }

            .lotus-list-item-wrapper {
                list-style: none;
            }

            .lotus-list-split .lotus-list-items > .lotus-list-item-wrapper:not(:last-child) {
                border-bottom: 1px solid var(--lotus-color-border);
            }

            .lotus-list-horizontal.lotus-list-split .lotus-list-items > .lotus-list-item-wrapper:not(:last-child) {
                border-bottom: none;
                border-right: 1px solid var(--lotus-color-border);
            }

            .lotus-list-small .lotus-list-item-wrapper {
                padding: var(--lotus-spacing-tight) 0;
            }

            .lotus-list-default .lotus-list-item-wrapper {
                padding: var(--lotus-spacing-base) 0;
            }

            .lotus-list-large .lotus-list-item-wrapper {
                padding: var(--lotus-spacing-base-loose) 0;
            }

            .lotus-list-empty {
                padding: var(--lotus-spacing-extra-loose);
                text-align: center;
                color: var(--lotus-color-text-2);
            }

            .lotus-list-load-more {
                padding: var(--lotus-spacing-base) var(--lotus-spacing-base-loose);
                text-align: center;
            }
        </style>
    </>
}
