import { Foundation, type Adapter } from '../../base/adapter.js';
import { validatePinChar, toValueList, distributePaste, type PinCodeFormat } from './pin-code-data.js';

export * from './pin-code-data.js';

export interface PinCodeState {
  valueList: string[];
}

export interface PinCodeFoundationOptions {
  count: number;
  format: PinCodeFormat;
}

export interface WriteResult {
  valueList: string[];
  focusIndex: number | null;
  completed: boolean;
}

export type FocusMoveKey = 'Backspace' | 'Delete' | 'ArrowLeft' | 'ArrowRight';

/**
 * PinCode 状态机：字符校验、单格写入、焦点跳转索引计算、粘贴分发。移植自
 * Semi semi-foundation/pinCode/foundation.ts 的算法思路（对齐参考实现
 * chenzy.design 已验证的设计）。真正的 DOM focus()/blur() 调用留给
 * `.tsrx` 组件层（Foundation 只返回"应该聚焦哪个索引"，不持有任何 DOM
 * 引用），对齐 lotus 既有的 Foundation 不碰 DOM 惯例。
 *
 * 忠实对齐 Semi 的行为怪癖（非 bug，是如实记录 Semi 的真实语义）：
 * 1. Backspace 无条件清空当前格并回退焦点，不判断当前格是否已空；
 * 2. onComplete 的判定条件是"写入的索引是否为末格"，不是"valueList 全部
 *    非空"——如果程序化/粘贴场景跳过中间格直接写末格，仍会触发 complete。
 * 主动修正 Semi 的技术债：
 * 1. count/value 变化时 valueList 用 toValueList 归一化（不足补空、超长
 *    截断），不像 Semi 那样残留脏长度数据。
 */
export class PinCodeFoundation extends Foundation<PinCodeState> {
  private opts: PinCodeFoundationOptions;

  constructor(adapter: Adapter<PinCodeState>, opts: PinCodeFoundationOptions) {
    super(adapter);
    this.opts = opts;
  }

  /** 单格写入合法字符：写入 → 推进焦点到下一格（若是末格则不再推进，标记 completed）。 */
  writeChar(index: number, char: string, isControlled: boolean): WriteResult | null {
    if (!validatePinChar(char, this.opts.format)) return null;
    const { valueList } = this.getState();
    const next = [...valueList];
    next[index] = char;
    const completed = index >= this.opts.count - 1;
    const focusIndex = completed ? null : index + 1;
    if (!isControlled) this.setState({ valueList: next });
    return { valueList: next, focusIndex, completed };
  }

  /** Backspace/Delete/ArrowLeft/ArrowRight 统一处理，返回焦点应该移动到的索引（不移动时返回 null）。 */
  handleFocusMoveKey(key: FocusMoveKey, index: number, isControlled: boolean): { valueList: string[]; focusIndex: number } | null {
    const { valueList } = this.getState();
    const count = this.opts.count;
    if (key === 'Backspace') {
      const next = [...valueList];
      next[index] = '';
      if (!isControlled) this.setState({ valueList: next });
      return { valueList: next, focusIndex: Math.max(0, index - 1) };
    }
    if (key === 'Delete') {
      const next = [...valueList];
      next[index] = '';
      if (!isControlled) this.setState({ valueList: next });
      return { valueList: next, focusIndex: Math.min(count - 1, index + 1) };
    }
    if (key === 'ArrowLeft') {
      return { valueList, focusIndex: Math.max(0, index - 1) };
    }
    return { valueList, focusIndex: Math.min(count - 1, index + 1) };
  }

  /** 粘贴分发：从 startIndex 开始写入，返回新 valueList 与应聚焦的索引。 */
  handlePaste(startIndex: number, text: string, isControlled: boolean): { valueList: string[]; focusIndex: number; completed: boolean } {
    const { valueList } = this.getState();
    const result = distributePaste(valueList, startIndex, text, this.opts.format);
    if (!isControlled) this.setState({ valueList: result.valueList });
    return { valueList: result.valueList, focusIndex: result.focusIndex, completed: result.reachedLast };
  }

  /** 受控同步 / count 变化：归一化到 count 长度。 */
  syncValueList(value: string | undefined): void {
    this.setState({ valueList: toValueList(value, this.opts.count) });
  }
}
