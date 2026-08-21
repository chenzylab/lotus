/**
 * PinCode 核心纯函数：字符校验、valueList 归一化、粘贴分发换算。移植自
 * Semi semi-foundation/pinCode/foundation.ts 的算法思路（对齐参考实现
 * chenzy.design 已验证的纯函数设计）。
 *
 * format 只支持 'number' | 'mixed' | RegExp | function 四种——Semi 源码
 * 类型签名就是这四种，测试文件里出现的 'text' 只是恰好落进默认放行分支
 * 造成的假象，不是被支持的正式枚举值，不照搬进 lotus 的类型定义。
 * 不实现 'mask' 遮罩显示——Semi 源码完全没有这个能力，PinCode 定位为
 * "可见分格短码"，需要遮蔽显示的场景应该用 Input type="password"。
 */
export type PinCodeFormat = 'number' | 'mixed' | RegExp | ((value: string) => boolean);

/** 单字符校验，对齐 Semi validateValue：不匹配任何已知模式时默认放行（不拦截）。 */
export function validatePinChar(char: string, format: PinCodeFormat): boolean {
  if (format === 'number') return /^\d$/.test(char);
  if (format === 'mixed') return /^[a-zA-Z0-9]$/.test(char);
  if (format instanceof RegExp) return format.test(char);
  if (typeof format === 'function') return format(char);
  return true;
}

/** 把整串字符串归一化成定长 valueList（不足补空字符串，超长截断），对齐调研 §4 指出的 Semi 缺陷主动修正。 */
export function toValueList(value: string | undefined, count: number): string[] {
  const chars = (value ?? '').split('').slice(0, count);
  const list = [...chars];
  while (list.length < count) {
    list.push('');
  }
  return list;
}

export interface PasteDistributionResult {
  valueList: string[];
  /** 分发结束后应该聚焦的格索引。 */
  focusIndex: number;
  /** 是否写入了末格（用于判定 onComplete）。 */
  reachedLast: boolean;
}

/**
 * 粘贴文本分发：从 startIndex 开始逐字符写入，遇到第一个不合法字符立即
 * 停止（不跳过继续找下一个合法字符），对齐 Semi handlePaste 的行为。
 */
export function distributePaste(
  valueList: string[],
  startIndex: number,
  text: string,
  format: PinCodeFormat,
): PasteDistributionResult {
  const next = [...valueList];
  const count = valueList.length;
  let i = startIndex;
  let charIndex = 0;
  let lastWritten = startIndex - 1;
  while (i < count && charIndex < text.length) {
    const char = text[charIndex]!;
    if (!validatePinChar(char, format)) break;
    next[i] = char;
    lastWritten = i;
    i++;
    charIndex++;
  }
  const focusIndex = Math.min(count - 1, lastWritten + 1);
  return { valueList: next, focusIndex, reachedLast: lastWritten === count - 1 };
}
