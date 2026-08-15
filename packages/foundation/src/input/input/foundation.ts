import { Foundation, type Adapter } from '../../base/adapter.js';

export interface InputState {
  value: string;
  isFocus: boolean;
  isHovering: boolean;
  /** 密码模式下，眼睛图标是否处于"已点开显示明文"状态。 */
  eyeOpen: boolean;
}

/**
 * Input 的受控/非受控 + composition（输入法组合）+ 清除/密码可见性状态机。
 * 设计参考 Semi InputFoundation 的判定思路（`_isControlledComponent()`、
 * composition 期间只更新展示值不触发 onChange），重新实现，不搬运代码。
 * lotus 的 Adapter 接口只有 `getState`/`setState`，没有 Semi 那种逐事件的
 * `notifyXxx` 转发层，采用 Switch 已验证的"回调作为方法参数传入"范式。
 */
export class InputFoundation extends Foundation<InputState> {
  /** 组合输入期间的私有标志位，不放进 state（对齐 Semi 用实例字段而非响应式状态存放）。 */
  private compositionEnter = false;

  /**
   * 原生 input 事件回调：composition 模式下（composition=true 且正处于组合中）
   * 只更新展示值，不对外触发 onChange；否则正常受控/非受控分支上报。
   */
  handleInput(
    value: string,
    event: Event,
    isControlled: boolean,
    composition: boolean,
    onChange?: (value: string, event: Event) => void,
  ): void {
    if (composition && this.compositionEnter) {
      this.setState({ value });
      return;
    }
    if (!isControlled) this.setState({ value });
    onChange?.(value, event);
  }

  handleCompositionStart(event: CompositionEvent, onCompositionStart?: (event: CompositionEvent) => void): void {
    this.compositionEnter = true;
    onCompositionStart?.(event);
  }

  handleCompositionUpdate(event: CompositionEvent, onCompositionUpdate?: (event: CompositionEvent) => void): void {
    onCompositionUpdate?.(event);
  }

  /**
   * composition=true 时，组合确认后在这里才真正触发一次 onChange（对外语义：
   * 组合期间完全不触发 onChange，只在确认后触发一次最终值）。composition=false
   * 时不重复触发——handleInput 已经在每次原生 input 事件时都触发过了。
   */
  handleCompositionEnd(
    value: string,
    event: CompositionEvent,
    isControlled: boolean,
    composition: boolean,
    onChange?: (value: string, event: Event) => void,
    onCompositionEnd?: (event: CompositionEvent) => void,
  ): void {
    this.compositionEnter = false;
    onCompositionEnd?.(event);
    if (composition) {
      if (!isControlled) this.setState({ value });
      onChange?.(value, event);
    }
  }

  handleClear(event: MouseEvent, isControlled: boolean, onChange?: (value: string, event: Event) => void, onClear?: (event: MouseEvent) => void): void {
    if (!isControlled) this.setState({ value: '' });
    onChange?.('', event);
    onClear?.(event);
  }

  handleFocus(event: FocusEvent, onFocus?: (event: FocusEvent) => void): void {
    this.setState({ isFocus: true });
    onFocus?.(event);
  }

  handleBlur(event: FocusEvent, onBlur?: (event: FocusEvent) => void): void {
    this.setState({ isFocus: false });
    onBlur?.(event);
  }

  handleMouseEnter(): void {
    this.setState({ isHovering: true });
  }

  handleMouseLeave(): void {
    this.setState({ isHovering: false });
  }

  toggleEye(): void {
    const { eyeOpen } = this.getState();
    this.setState({ eyeOpen: !eyeOpen });
  }

  /** 清除按钮显示条件：有内容 + 开启 showClear + (聚焦或悬浮) + 未禁用。 */
  static isAllowClear(value: string, showClear: boolean, disabled: boolean, isFocus: boolean, isHovering: boolean): boolean {
    return !!value && showClear && !disabled && (isFocus || isHovering);
  }
}
