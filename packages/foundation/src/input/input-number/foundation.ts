import { Foundation, type Adapter } from '../../base/adapter.js';

export interface InputNumberState {
  /** 输入框里展示的原始字符串——用户正在输入时可能是 "1."/"-"/"" 这类还没解析
   *  成合法数值的中间态，不能在每次按键时都立刻 clamp/格式化，否则用户永远
   *  打不出小数点或负号。只有 blur/Enter 时才把它规整成最终的合法数值字符串。 */
  inputValue: string;
  /** 已解析、已 clamp 过的当前数值；输入框内容不是合法数字时为 undefined。 */
  value: number | undefined;
  isFocus: boolean;
}

export interface InputNumberBounds {
  min: number;
  max: number;
  step: number;
}

/**
 * InputNumber 的受控/非受控 + 步进 + 边界钳制状态机。与 InputFoundation
 * （纯字符串管理）语义不同，这里额外需要"字符串 -> 数值 -> clamp -> 字符串"
 * 的转换链路，不适合直接复用 InputFoundation，新建独立 Foundation。
 */
export class InputNumberFoundation extends Foundation<InputNumberState> {
  /** clamp 到 [min, max] 区间，非数字（NaN）原样返回 undefined。 */
  static clamp(value: number, bounds: InputNumberBounds): number {
    return Math.min(bounds.max, Math.max(bounds.min, value));
  }

  /** 把用户输入的原始字符串解析成数值；空字符串/非法输入返回 undefined，
   *  不在这一步 clamp——中间输入态（"1."/"-"）允许暂时超出/不构成合法数字。 */
  static parse(raw: string): number | undefined {
    if (raw.trim() === '') return undefined;
    const n = Number(raw);
    return Number.isNaN(n) ? undefined : n;
  }

  /**
   * 每次按键触发：只更新展示字符串 + 尝试解析出的数值（不 clamp、不四舍五入），
   * 让用户可以自由输入中间态。受控模式下把解析出的合法数值上报给 onChange；
   * 非法中间态（无法解析成数字）不触发 onChange，等用户输入完整再说。
   */
  handleInput(raw: string, isControlled: boolean, onChange?: (value: number | undefined) => void): void {
    const parsed = InputNumberFoundation.parse(raw);
    if (!isControlled) {
      this.setState({ inputValue: raw, value: parsed });
    } else {
      this.setState({ inputValue: raw });
    }
    if (parsed !== undefined) {
      onChange?.(parsed);
    }
  }

  /**
   * 失焦/Enter 时的最终规整：把当前值 clamp 到边界内，重新生成展示字符串。
   * 空输入不强制变成 0——保持 undefined，对齐 Semi「不强加默认值」的语义。
   */
  handleBlur(bounds: InputNumberBounds, isControlled: boolean, onChange?: (value: number | undefined) => void): void {
    const { inputValue, value } = this.getState();
    this.setState({ isFocus: false });

    const parsed = value ?? InputNumberFoundation.parse(inputValue);
    if (parsed === undefined) {
      this.setState({ inputValue: '' });
      return;
    }
    const clamped = InputNumberFoundation.clamp(parsed, bounds);
    const nextInputValue = String(clamped);
    if (!isControlled) {
      this.setState({ inputValue: nextInputValue, value: clamped });
    } else {
      this.setState({ inputValue: nextInputValue });
    }
    if (clamped !== parsed) {
      onChange?.(clamped);
    }
  }

  handleFocus(): void {
    this.setState({ isFocus: true });
  }

  /**
   * 清除按钮：与 `handleInput('', ...)` 语义不同，不能复用——`handleInput`
   * 是给"用户正在打字，中间态可能是暂时无法解析的字符串"这个场景设计的，
   * 空字符串解析结果恒为 `undefined`，`onChange` 只在能解析出合法数值时才
   * 触发，导致复用它实现清除按钮时 `onChange` 永远不会被调用（真实 bug，
   * 曾复现为"受控模式下点击清除按钮界面毫无反应，非受控模式下视觉清空但
   * 外部完全不知情"）。清除是一个明确的"清空"意图，不是"打出了一个恰好
   * 解析失败的字符串"，因此无条件触发 `onChange(undefined)`，不像
   * `handleInput` 那样有"解析成功才通知外部"的前提。
   */
  handleClear(isControlled: boolean, onChange?: (value: number | undefined) => void): void {
    if (!isControlled) {
      this.setState({ inputValue: '', value: undefined });
    } else {
      this.setState({ inputValue: '' });
    }
    onChange?.(undefined);
  }

  /**
   * 步进器加/减：基于当前值（缺省时取 0）按 step/shiftStep clamp 后的新值，
   * disabled 时不响应。
   */
  handleStep(
    direction: 1 | -1,
    bounds: InputNumberBounds,
    isControlled: boolean,
    disabled: boolean,
    onChange?: (value: number | undefined) => void,
  ): void {
    if (disabled) return;
    const { value } = this.getState();
    const base = value ?? 0;
    const next = InputNumberFoundation.clamp(base + direction * bounds.step, bounds);
    const nextInputValue = String(next);
    if (!isControlled) {
      this.setState({ inputValue: nextInputValue, value: next });
    } else {
      this.setState({ inputValue: nextInputValue });
    }
    onChange?.(next);
  }

  static isStepDisabled(direction: 1 | -1, value: number | undefined, bounds: InputNumberBounds, disabled: boolean): boolean {
    if (disabled) return true;
    if (value === undefined) return false;
    return direction === 1 ? value >= bounds.max : value <= bounds.min;
  }
}
