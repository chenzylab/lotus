/**
 * 分隔符拆分，移植自 Semi semi-foundation/tagInput/utils/getSplitedArray.ts
 * 的算法（对齐参考实现 chenzy.design 的等价 TS 移植版本）。支持字符串或
 * 字符串数组（多分隔符），不支持正则表达式——传入非 string/string[] 时
 * 原样返回整串作为单一元素，与 Semi 运行时行为一致（TS 类型层面不允许，
 * 但没有额外防御）。
 */
export type Separator = string | string[] | null | undefined;

export function splitBySeparator(input: string, separator: Separator): string[] {
  if (typeof separator === 'string') return input.split(separator);
  if (Array.isArray(separator) && separator.length > 0) {
    const primary = separator[0]!;
    let joined = input;
    for (let i = 1; i < separator.length; i++) {
      joined = joined.split(separator[i]!).join(primary);
    }
    return joined.split(primary);
  }
  return [input];
}
