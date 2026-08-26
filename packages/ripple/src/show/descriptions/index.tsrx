import { track } from 'ripple';
import { groupByColumn, filterVisible, type DescriptionsItemData } from '@lotus/foundation/show/descriptions';

export type DescriptionsAlign = 'center' | 'justify' | 'left' | 'plain';
export type DescriptionsSize = 'small' | 'medium' | 'large';
export type DescriptionsLayout = 'horizontal' | 'vertical';

export interface DescriptionsProps {
    data?: DescriptionsItemData[];
    align?: DescriptionsAlign;
    row?: boolean;
    size?: DescriptionsSize;
    layout?: DescriptionsLayout;
    column?: number;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

function resolveValue(value: any): any {
    return typeof value === 'function' ? value() : value;
}

export function Descriptions(&{
    data = [],
    align = 'center',
    row = false,
    size = 'medium',
    layout = 'vertical',
    column = 3,
    style,
    class: className,
    'aria-label': ariaLabel,
}: DescriptionsProps) @{
    let &[classes] = track<string>(() =>
        [
            'lotus-descriptions',
            row ? `lotus-descriptions-double lotus-descriptions-double-${size}` : `lotus-descriptions-${align}`,
            layout === 'horizontal' ? 'lotus-descriptions-horizontal' : '',
            className ?? '',
        ].filter(Boolean).join(' '),
    );

    let &[rows] = track<DescriptionsItemData[][]>(() =>
        layout === 'horizontal' ? groupByColumn(data, column) : filterVisible(data).map((item) => [item]),
    );

    <>
        <div class={classes} style={style} aria-label={ariaLabel}>
            <table class="lotus-descriptions-table">
                <tbody>
                    @for (const group of rows; index rowIndex) {
                        <tr class="lotus-descriptions-row">
                            @for (const item of group; index colIndex; key item.key) {
                                <>
                                    @if (align !== 'plain') {
                                        <>
                                            <th class="lotus-descriptions-item-th" style={item.keyStyle}>
                                                <span class="lotus-descriptions-key">{item.key}</span>
                                            </th>
                                            <td class={['lotus-descriptions-item-td', item.className ?? ''].filter(Boolean).join(' ')} colspan={(item.span ?? 1) * 2 - 1} style={item.style}>
                                                <span class="lotus-descriptions-value">{resolveValue(item.value)}</span>
                                            </td>
                                        </>
                                    }
                                    @if (align === 'plain') {
                                        <td class={['lotus-descriptions-item-plain', item.className ?? ''].filter(Boolean).join(' ')} colspan={item.span ?? 1} style={item.style}>
                                            <span class="lotus-descriptions-key" style={item.keyStyle}>{item.key}:</span>
                                            <span class="lotus-descriptions-value">{resolveValue(item.value)}</span>
                                        </td>
                                    }
                                </>
                            }
                        </tr>
                    }
                </tbody>
            </table>
        </div>

        <style>
            .lotus-descriptions-table {
                width: 100%;
                border-collapse: collapse;
                table-layout: auto;
            }

            .lotus-descriptions-key {
                white-space: nowrap;
                color: var(--lotus-color-text-2);
                font-size: var(--lotus-font-body-size);
                font-weight: 400;
            }

            .lotus-descriptions-value {
                color: var(--lotus-color-text-0);
                font-size: var(--lotus-font-body-size);
                word-break: break-word;
            }

            .lotus-descriptions-item-th,
            .lotus-descriptions-item-td {
                padding: var(--lotus-spacing-tight) 0;
                text-align: start;
                vertical-align: top;
            }

            .lotus-descriptions-item-th {
                padding-inline-end: var(--lotus-spacing-base);
                width: 1px;
            }

            .lotus-descriptions-item-plain {
                padding-block: var(--lotus-spacing-tight);
                padding-inline-end: var(--lotus-spacing-base);
                vertical-align: top;
            }

            .lotus-descriptions-item-plain .lotus-descriptions-key {
                display: inline-block;
                margin-inline-end: var(--lotus-spacing-extra-tight);
            }

            .lotus-descriptions-item-plain .lotus-descriptions-value {
                display: inline-block;
            }

            .lotus-descriptions-justify .lotus-descriptions-item-th {
                text-align: justify;
            }

            .lotus-descriptions-left .lotus-descriptions-item-th {
                text-align: left;
            }

            .lotus-descriptions-double .lotus-descriptions-table,
            .lotus-descriptions-double tbody {
                display: flex;
                flex-wrap: wrap;
            }

            .lotus-descriptions-double .lotus-descriptions-row {
                display: flex;
                flex-direction: column;
                margin-inline-end: var(--lotus-spacing-extra-loose);
                margin-bottom: var(--lotus-spacing-tight);
            }

            .lotus-descriptions-double .lotus-descriptions-value {
                font-weight: 600;
            }

            .lotus-descriptions-double-small .lotus-descriptions-key,
            .lotus-descriptions-double-small .lotus-descriptions-value {
                font-size: var(--lotus-font-label-size);
            }

            .lotus-descriptions-double-large .lotus-descriptions-key,
            .lotus-descriptions-double-large .lotus-descriptions-value {
                font-size: var(--lotus-font-h6-size);
            }
        </style>
    </>
}
