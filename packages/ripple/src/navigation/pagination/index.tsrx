import { track, effect, untrack } from 'ripple';
import {
    computePageList,
    getTotalPageNumber,
    computeCurrentPageAfterPageSizeChange,
    clampCurrentPage,
    type PageListItem,
} from '@lotus/foundation/navigation/pagination';
import { Select } from '../../input/select/index.tsrx';
import { IconChevronLeft, IconChevronRight } from '@lotus/icons';

export type PaginationSize = 'default' | 'small';

export interface PaginationProps {
    total: number;
    pageSize?: number;
    currentPage?: number;
    defaultCurrentPage?: number;
    pageSizeOpts?: number[];
    showSizeChanger?: boolean;
    showQuickJumper?: boolean;
    showTotal?: boolean | ((total: number, range: [number, number]) => any);
    size?: PaginationSize;
    disabled?: boolean;
    preventPageChangeOnPageSizeChange?: boolean;
    onChange?: (currentPage: number, pageSize: number) => void;
    onPageChange?: (currentPage: number) => void;
    onPageSizeChange?: (pageSize: number) => void;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

const DEFAULT_PAGE_SIZE_OPTS = [10, 20, 40, 100];

/**
 * Pagination：省略号截断算法（computePageList）纯函数自研，对齐 Semi
 * 的分支逻辑但重写实现。快速跳转用原生 input + keydown 监听（Input 组件
 * 无 onEnterPress 封装），pageSize 选择器复用已有的 Select 组件。
 */
export function Pagination(&{
    total,
    pageSize: pageSizeProp,
    currentPage: currentPageProp,
    defaultCurrentPage = 1,
    pageSizeOpts = DEFAULT_PAGE_SIZE_OPTS,
    showSizeChanger = false,
    showQuickJumper = false,
    showTotal = false,
    size = 'default',
    disabled = false,
    preventPageChangeOnPageSizeChange = false,
    onChange,
    onPageChange,
    onPageSizeChange,
    style,
    class: className,
    'aria-label': ariaLabel,
}: PaginationProps) @{
    const isControlled = currentPageProp !== undefined;
    let &[pageSize] = track<number>(pageSizeProp ?? pageSizeOpts[0] ?? 10);
    let &[state] = track<number>(defaultCurrentPage);
    let &[jumpInputValue] = track<string>('');

    effect(() => {
        if (pageSizeProp === undefined) return;
        if (untrack(() => pageSize) === pageSizeProp) return;
        pageSize = pageSizeProp;
    });

    let &[displayCurrentPage] = track<number>(() => {
        const raw = isControlled ? currentPageProp! : state;
        return clampCurrentPage(raw, getTotalPageNumber(total, pageSize));
    });

    let &[totalPageNum] = track<number>(() => getTotalPageNumber(total, pageSize));
    let &[pageList] = track<PageListItem[]>(() => computePageList(displayCurrentPage, totalPageNum).pageList);

    function updatePage(target: number) {
        const clamped = clampCurrentPage(target, totalPageNum);
        if (clamped === untrack(() => displayCurrentPage)) return;
        if (!isControlled) state = clamped;
        onPageChange?.(clamped);
        onChange?.(clamped, untrack(() => pageSize));
    }

    function goPage(item: PageListItem) {
        if (item === '...') return;
        updatePage(item);
    }

    function goPrev() {
        updatePage(untrack(() => displayCurrentPage) - 1);
    }

    function goNext() {
        updatePage(untrack(() => displayCurrentPage) + 1);
    }

    function handlePageSizeChange(value: any) {
        const newPageSize = Number(value);
        const oldPageSize = untrack(() => pageSize);
        pageSize = newPageSize;
        onPageSizeChange?.(newPageSize);

        const current = untrack(() => displayCurrentPage);
        const newCurrentPage = preventPageChangeOnPageSizeChange
            ? current
            : clampCurrentPage(computeCurrentPageAfterPageSizeChange(current, oldPageSize, newPageSize), getTotalPageNumber(total, newPageSize));

        if (!isControlled) state = newCurrentPage;
        if (newCurrentPage !== current) onPageChange?.(newCurrentPage);
        onChange?.(newCurrentPage, newPageSize);
    }

    function handleJumpKeyDown(event: KeyboardEvent) {
        if (event.key !== 'Enter') return;
        const target = untrack(() => jumpInputValue);
        const parsed = parseInt(target, 10);
        if (!Number.isNaN(parsed)) {
            updatePage(parsed);
        }
        jumpInputValue = '';
    }

    let &[classes] = track<string>(() =>
        [
            'lotus-pagination',
            `lotus-pagination-size-${size}`,
            disabled ? 'lotus-pagination-disabled' : '',
            className ?? '',
        ]
            .filter(Boolean)
            .join(' '),
    );

    let &[rangeText] = track<any>(() => {
        if (!showTotal) return null;
        const start = (displayCurrentPage - 1) * pageSize + 1;
        const end = Math.min(displayCurrentPage * pageSize, total);
        if (typeof showTotal === 'function') return showTotal(total, [start, end]);
        return `共 ${total} 条`;
    });

    <>
        <div class={classes} style={style} aria-label={ariaLabel} role="navigation">
            @if (rangeText) {
                <div class="lotus-pagination-total">{rangeText}</div>
            }

            <button
                type="button"
                class="lotus-pagination-item lotus-pagination-prev"
                disabled={disabled || displayCurrentPage <= 1}
                aria-label="上一页"
                onClick={goPrev}
            >
                <IconChevronLeft />
            </button>

            @for (const item of pageList; index i) {
                <>
                    @if (item === '...') {
                        <span class="lotus-pagination-item lotus-pagination-ellipsis">...</span>
                    } @if (item !== '...') {
                        <button
                            type="button"
                            class={item === displayCurrentPage ? 'lotus-pagination-item lotus-pagination-item-active' : 'lotus-pagination-item'}
                            disabled={disabled}
                            aria-current={item === displayCurrentPage ? 'page' : undefined}
                            aria-label={`第 ${item} 页`}
                            onClick={() => goPage(item)}
                        >
                            {item}
                        </button>
                    }
                </>
            }

            <button
                type="button"
                class="lotus-pagination-item lotus-pagination-next"
                disabled={disabled || displayCurrentPage >= totalPageNum}
                aria-label="下一页"
                onClick={goNext}
            >
                <IconChevronRight />
            </button>

            @if (showSizeChanger) {
                <Select
                    class="lotus-pagination-size-changer"
                    size={size === 'small' ? 'small' : 'default'}
                    value={pageSize}
                    disabled={disabled}
                    optionList={pageSizeOpts.map((opt) => ({ value: opt, label: `${opt} 条/页` }))}
                    onChange={handlePageSizeChange}
                    aria-label="每页条数"
                />
            }

            @if (showQuickJumper) {
                <div class="lotus-pagination-quick-jumper">
                    <span>跳至</span>
                    <input
                        type="text"
                        inputmode="numeric"
                        class="lotus-pagination-quick-jumper-input"
                        disabled={disabled}
                        value={jumpInputValue}
                        aria-label="跳转到指定页码"
                        onInput={(event: Event) => { jumpInputValue = (event.target as HTMLInputElement).value; }}
                        onKeyDown={handleJumpKeyDown}
                    />
                    <span>页</span>
                </div>
            }
        </div>

        <style>
            .lotus-pagination {
                display: flex;
                align-items: center;
                gap: var(--lotus-spacing-tight);
                flex-wrap: wrap;
            }

            .lotus-pagination-disabled {
                opacity: 0.5;
                pointer-events: none;
            }

            .lotus-pagination-total {
                font-size: var(--lotus-font-body-size);
                color: var(--lotus-color-text-1);
                margin-right: var(--lotus-spacing-tight);
            }

            .lotus-pagination-item {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                min-width: var(--lotus-height-control-small);
                height: var(--lotus-height-control-small);
                padding: 0 6px;
                border: none;
                border-radius: var(--lotus-border-radius-small);
                background: transparent;
                color: var(--lotus-color-text-0);
                font-size: var(--lotus-font-body-size);
                cursor: pointer;
            }

            .lotus-pagination-size-small .lotus-pagination-item {
                min-width: 22px;
                height: 22px;
                font-size: var(--lotus-font-label-size);
            }

            .lotus-pagination-item:hover:not(:disabled) {
                background: var(--lotus-color-fill-0);
            }

            .lotus-pagination-item:disabled {
                color: var(--lotus-color-disabled-text);
                cursor: not-allowed;
            }

            .lotus-pagination-item-active {
                background: var(--lotus-color-primary);
                color: #ffffff;
            }

            .lotus-pagination-item-active:hover:not(:disabled) {
                background: var(--lotus-color-primary-hover);
            }

            .lotus-pagination-ellipsis {
                cursor: default;
            }

            .lotus-pagination-size-changer {
                width: 110px;
                flex-shrink: 0;
            }

            .lotus-pagination-quick-jumper {
                display: flex;
                align-items: center;
                gap: 6px;
                font-size: var(--lotus-font-body-size);
                color: var(--lotus-color-text-1);
                flex-shrink: 0;
            }

            .lotus-pagination-quick-jumper-input {
                width: 40px;
                height: var(--lotus-height-control-small);
                padding: 0 6px;
                border: var(--lotus-border-width-control) solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-small);
                text-align: center;
                font-family: var(--lotus-font-family);
                font-size: var(--lotus-font-body-size);
                color: var(--lotus-color-text-0);
                background: var(--lotus-color-bg-1);
            }

            .lotus-pagination-quick-jumper-input:focus {
                outline: none;
                border-color: var(--lotus-color-primary);
            }
        </style>
    </>
}
