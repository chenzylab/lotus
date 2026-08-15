import { Foundation, type Adapter } from '../../base/adapter.js';

export interface TextAreaState {
  value: string;
  isFocus: boolean;
  isHovering: boolean;
}

/**
 * TextArea 的受控/非受控 + composition 状态机，与 InputFoundation 同构（Semi 官方也是
 * 两个独立 Foundation 文件，行为高度重复但保持独立以避免 Input/TextArea 语义耦合）。
 */
export class TextAreaFoundation extends Foundation<TextAreaState> {
  private compositionEnter = false;

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

  static isAllowClear(value: string, showClear: boolean, disabled: boolean, readonly: boolean, isFocus: boolean, isHovering: boolean): boolean {
    return !!value && showClear && !disabled && !readonly && (isFocus || isHovering);
  }
}
