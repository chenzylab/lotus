import { track } from 'ripple';
import { groupByColumn, filterVisible, type DescriptionsItemData } from '@lotus/foundation/show/descriptions';
import { DescriptionsContext } from './descriptions-context.js';

export type DescriptionsAlign = 'center' | 'justify' | 'left' | 'plain';
export type DescriptionsSize = 'small' | 'medium' | 'large';
export type DescriptionsLayout = 'horizontal' | 'vertical';

/**
 * children 声明式写法（<Descriptions><DescriptionsItem .../></Descriptions>）
 * 只在 layout==='vertical'（默认值）时支持，对齐 Semi render() 里
 * `data && data.length ? ... : children` 的分支——vertical 布局下 children
 * 不需要收集信息就能直接渲染（每个 Item 独立成 <tr>，互不影响）。
 * layout==='horizontal' 需要先把全部 item 按 column 总列数分组换行
 * （getHorizontalList 算法），这要求父组件能拿到"全部子节点的完整列表"
 * 才能分组——Semi 靠 React.Children.toArray 做到，Ripple 没有等价机制
 * （子组件向父组件"注册自己"需要显式的 registerItem 模式，参照
 * ResizeGroup/ResizeItem 的先例，但那套机制主要为处理动态增删/顺序敏感
 * 场景设计，Descriptions 的 horizontal+children 组合在实际使用中远少于
 * data 数组配置——数据来源多为后端接口，数组形式更自然），是已知的
 * 架构限制，本次不实现，用 data 数组配置替代。
 */
export interface DescriptionsProps {
    children?: any;
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
    children,
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

    // horizontal 布局的 children 声明式写法不支持（见上方架构限制说明），
    // 即使传了 children 也走 data 数组路径（此时 data 为空，渲染空表格，
    // 跟"没有可用数据"的自然结果一致，不是特殊分支）。
    const useChildren = layout === 'vertical' && data.length === 0 && children !== undefined;

    let &[rows] = track<DescriptionsItemData[][]>(() =>
        layout === 'horizontal' ? groupByColumn(data, column) : filterVisible(data).map((item) => [item]),
    );

    let &[, contextTracked] = track(() => ({ align }));
    DescriptionsContext.set(contextTracked);

    <>
        <div class={classes} style={style} aria-label={ariaLabel}>
            <table class="lotus-descriptions-table">
                <tbody>
                    @if (useChildren) {
                        <>{children}</>
                    }
                    @if (!useChildren) {
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
