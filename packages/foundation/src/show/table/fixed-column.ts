import type { ColumnDef } from './table-data.js';

/**
 * 固定列像素偏移量计算，移植自 Semi getCellWidths 的算法思路：固定列效果
 * 是给对应单元格手动写入内联 style.left/style.right（不是 CSS position:
 * sticky），偏移量是"前面/后面所有固定在同一侧的列的实测宽度累加"。
 * 真实宽度来自渲染后测量的 DOM（由 .tsrx 组件层采样后传入 widths 数组），
 * Foundation 层只做纯粹的累加换算。
 */
export interface FixedOffsets {
  left: Array<number | null>;
  right: Array<number | null>;
}

export function calcFixedOffsets<T = any>(columns: ColumnDef<T>[], widths: number[]): FixedOffsets {
  const left: Array<number | null> = new Array(columns.length).fill(null);
  const right: Array<number | null> = new Array(columns.length).fill(null);

  let leftAcc = 0;
  for (let i = 0; i < columns.length; i++) {
    if (columns[i]!.fixed === 'left' || columns[i]!.fixed === true) {
      left[i] = leftAcc;
      leftAcc += widths[i] ?? 0;
    } else {
      break;
    }
  }

  let rightAcc = 0;
  for (let i = columns.length - 1; i >= 0; i--) {
    if (columns[i]!.fixed === 'right') {
      right[i] = rightAcc;
      rightAcc += widths[i] ?? 0;
    } else {
      break;
    }
  }

  return { left, right };
}

/** 是否存在任意固定列（决定要不要走双 table 架构）。 */
export function hasFixedColumns<T = any>(columns: ColumnDef<T>[]): boolean {
  return columns.some((col) => col.fixed === 'left' || col.fixed === 'right' || col.fixed === true);
}
