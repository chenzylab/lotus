/**
 * Descriptions 是纯展示型组件，没有内部状态机，Foundation 层只承载
 * "horizontal 布局下按 column 总列数分组换行"这一条与渲染无关的纯
 * 算法逻辑（移植自 Semi 的 getHorizontalList，用 lotus 语言习惯
 * 重新表达为无状态纯函数，不引入 Foundation 基类）。
 */

export interface DescriptionsItemData {
  key: any;
  value: any;
  hidden?: boolean;
  span?: number;
  keyStyle?: Record<string, any>;
  className?: string;
  style?: Record<string, any>;
}

/**
 * 把可见（未 hidden）的 item 按 span 累加分组，每组 totalSpan 达到或
 * 超过 column 就换行；若最后一组的 span 总和小于 column 且组内最后
 * 一项没有显式指定 span，把它的 span 补齐撑满整行（对齐 Semi 的
 * "最后一行自动填满"视觉效果，避免网格右侧出现不规则空白）。
 */
export function groupByColumn(
  items: DescriptionsItemData[],
  column: number,
): DescriptionsItemData[][] {
  const visible = items.filter((item) => !item.hidden);
  const groups: DescriptionsItemData[][] = [];
  let current: DescriptionsItemData[] = [];
  let totalSpan = 0;

  for (const item of visible) {
    const span = item.span ?? 1;
    totalSpan += span;
    current.push(item);
    if (totalSpan >= column) {
      groups.push(current);
      current = [];
      totalSpan = 0;
    }
  }

  if (current.length !== 0) {
    const lastItem = current[current.length - 1]!;
    if (lastItem.span === undefined) {
      const total = current.reduce((sum, item) => sum + (item.span ?? 1), 0);
      if (total < column) {
        current = [...current.slice(0, -1), { ...lastItem, span: column - total + 1 }];
      }
    }
    groups.push(current);
  }

  return groups;
}

export function filterVisible(items: DescriptionsItemData[]): DescriptionsItemData[] {
  return items.filter((item) => !item.hidden);
}
