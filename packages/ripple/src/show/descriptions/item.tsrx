import { track } from 'ripple';
import { DescriptionsContext } from './descriptions-context.js';

export interface DescriptionsItemProps {
    itemKey?: any;
    children?: any;
    hidden?: boolean;
    span?: number;
    keyStyle?: Record<string, any>;
    class?: string;
    style?: Record<string, any>;
}

/**
 * children 声明式写法的单条 item，只在 Descriptions 的 vertical 布局（默认值）
 * 下受支持——渲染跟 data 数组模式完全同构的 <tr> 结构（复用同一套 CSS 类名），
 * horizontal 布局下不支持这种写法（见 index.tsrx 顶部注释的架构限制说明）。
 */
export function DescriptionsItem(&{
    itemKey,
    children,
    hidden = false,
    span = 1,
    keyStyle,
    class: className,
    style,
}: DescriptionsItemProps) @{
    const contextTracked = DescriptionsContext.get();
    let &[align] = track(() => contextTracked?.value.align ?? 'center');

    function resolveValue(value: any): any {
        return typeof value === 'function' ? value() : value;
    }

    <>
        @if (!hidden) {
            <tr class={['lotus-descriptions-row', className ?? ''].filter(Boolean).join(' ')} style={style}>
                @if (align !== 'plain') {
                    <>
                        <th class="lotus-descriptions-item-th" style={keyStyle}>
                            <span class="lotus-descriptions-key">{itemKey}</span>
                        </th>
                        <td class="lotus-descriptions-item-td" colspan={span * 2 - 1}>
                            <span class="lotus-descriptions-value">{resolveValue(children)}</span>
                        </td>
                    </>
                }
                @if (align === 'plain') {
                    <td class="lotus-descriptions-item-plain" colspan={span}>
                        <span class="lotus-descriptions-key" style={keyStyle}>{itemKey}:</span>
                        <span class="lotus-descriptions-value">{resolveValue(children)}</span>
                    </td>
                }
            </tr>
        }
    </>
}
