import { Foundation, type Adapter } from '../../base/adapter.js';

export type AutoCompleteValue = string | number;
export type AutoCompleteDataItem = AutoCompleteValue | { value: AutoCompleteValue; label?: any; disabled?: boolean; [key: string]: any };

export interface AutoCompleteOptionItem {
  value: AutoCompleteValue;
  label: any;
  disabled: boolean;
  raw: AutoCompleteDataItem;
}

/**
 * 把 `data` prop（字符串/数字/对象三种输入形式）归一化成统一的候选项结构。
 * 对齐 Semi `_generateList`：直接原样转换，不做任何过滤/匹配——AutoComplete
 * 源码本身没有候选项过滤算法，`data` 展示什么完全由外部决定（消费方在自己的
 * `onSearch` 回调里算好新的 data 传回来），这是刻意的设计留白，不是遗漏。
 */
export function normalizeOptions(data: AutoCompleteDataItem[]): AutoCompleteOptionItem[] {
  return data.map((item) => {
    if (typeof item === 'object' && item !== null) {
      return { value: item.value, label: item.label ?? item.value, disabled: !!item.disabled, raw: item };
    }
    return { value: item, label: item, disabled: false, raw: item };
  });
}

/** 根据当前 inputValue 在候选项里找精确匹配的索引（打开面板/defaultActiveFirstOption
 * 时用来决定初始高亮项），找不到返回 -1。 */
export function findMatchedOptionIndex(options: AutoCompleteOptionItem[], inputValue: AutoCompleteValue | undefined): number {
  if (inputValue === undefined) return -1;
  return options.findIndex((o) => String(o.value) === String(inputValue));
}

/** 打开面板时的初始高亮索引：优先精确匹配当前 inputValue，否则
 * defaultActiveFirstOption 时高亮第一个非 disabled 项，否则不高亮。 */
export function computeInitialFocusIndex(options: AutoCompleteOptionItem[], inputValue: AutoCompleteValue | undefined, defaultActiveFirstOption: boolean): number {
  const matched = findMatchedOptionIndex(options, inputValue);
  if (matched >= 0 && !options[matched]!.disabled) return matched;
  if (!defaultActiveFirstOption) return -1;
  return options.findIndex((o) => !o.disabled);
}

/** 上下键移动焦点：从 currentIndex 往 direction 方向找最近的非 disabled 项，
 * 越界时循环回绕到另一端。全部 disabled 或候选为空时返回 -1。 */
export function moveFocusIndex(options: AutoCompleteOptionItem[], currentIndex: number, direction: 1 | -1): number {
  const count = options.length;
  if (count === 0) return -1;
  let next = currentIndex;
  for (let i = 0; i < count; i++) {
    next = (next + direction + count) % count;
    if (!options[next]!.disabled) return next;
  }
  return -1;
}

export interface AutoCompleteState {
  inputValue: AutoCompleteValue;
  visible: boolean;
  focusIndex: number;
}

/**
 * AutoComplete 的核心状态机：不做候选项过滤（见 normalizeOptions 注释），
 * 只负责浮层开关、键盘焦点移动、选中后的受控/非受控分支行为。触发器复用
 * 现有 Input 组件，浮层开关模式复用 Cascader 已验证的 Popover(trigger=
 * "custom") + document mousedown 双 contains 判断。
 */
export class AutoCompleteFoundation extends Foundation<AutoCompleteState> {
  constructor(adapter: Adapter<AutoCompleteState>) {
    super(adapter);
  }

  open(options: AutoCompleteOptionItem[], defaultActiveFirstOption: boolean): void {
    const { inputValue, visible } = this.getState();
    if (visible) return;
    const focusIndex = computeInitialFocusIndex(options, inputValue, defaultActiveFirstOption);
    this.setState({ visible: true, focusIndex });
  }

  close(): void {
    this.setState({ visible: false, focusIndex: -1 });
  }

  toggle(options: AutoCompleteOptionItem[], defaultActiveFirstOption: boolean): void {
    const { visible } = this.getState();
    if (visible) this.close();
    else this.open(options, defaultActiveFirstOption);
  }

  /** 点击触发器（输入框本身）：只负责确保面板打开，已打开时不做任何事。
   * 不能像 Cascader/TreeSelect 那样无条件 toggle——AutoComplete 的触发器
   * 是可编辑的文本框，用户输入过程中再次点击（如移动光标）也会冒泡到这里，
   * 若 toggle 会把正在使用的面板意外关闭。真正的关闭交给失焦/点击外部/Esc。 */
  openOnTriggerClick(options: AutoCompleteOptionItem[], defaultActiveFirstOption: boolean): void {
    const { visible } = this.getState();
    if (!visible) this.open(options, defaultActiveFirstOption);
  }

  /** 输入变化：更新 inputValue，重新定位 focusIndex，未打开则打开面板。
   * 不做过滤——onSearch 交给调用方处理，Foundation 只管自己的展示状态。 */
  handleSearch(value: AutoCompleteValue, options: AutoCompleteOptionItem[], defaultActiveFirstOption: boolean, isControlled: boolean): void {
    const { visible } = this.getState();
    if (!isControlled) this.setState({ inputValue: value });
    const focusIndex = computeInitialFocusIndex(options, value, defaultActiveFirstOption);
    if (!visible) {
      this.setState({ visible: true, focusIndex });
    } else {
      this.setState({ focusIndex });
    }
  }

  /** 选中候选项：受控模式下不自动回填 inputValue（交给外部通过 onChange
   * 决定是否接受这个建议值），非受控模式下直接回填——对齐 Semi 的核心语义
   * "AutoComplete 允许自由文本，选中只是给一个建议"。总是关闭浮层。 */
  handleSelect(option: AutoCompleteOptionItem, optionIndex: number, isControlled: boolean): AutoCompleteValue {
    if (!isControlled) {
      this.setState({ inputValue: option.value, visible: false, focusIndex: optionIndex });
    } else {
      this.setState({ visible: false, focusIndex: optionIndex });
    }
    return option.value;
  }

  handleArrowKey(options: AutoCompleteOptionItem[], direction: 1 | -1, defaultActiveFirstOption: boolean): void {
    const { visible, focusIndex } = this.getState();
    if (!visible) {
      this.open(options, defaultActiveFirstOption);
      return;
    }
    const next = moveFocusIndex(options, focusIndex, direction);
    this.setState({ focusIndex: next });
  }
}
