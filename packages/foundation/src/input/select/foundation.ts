import { Foundation, type Adapter } from '../../base/adapter.js';

export type SelectValue = string | number;

export interface SelectState {
  /** 单选存 SelectValue | undefined；多选存 SelectValue[]。 */
  value: SelectValue | SelectValue[] | undefined;
  /** 搜索框当前输入值，仅在 `filter` 开启时使用。 */
  searchInput: string;
}

export interface SelectFilterableOption {
  value: SelectValue;
  label?: any;
  disabled?: boolean;
}

/** 组合式 `<Select.OptGroup>` 声明产出的分组结构（对齐 Semi：分组仅
 * JSX children 声明支持，`optionList` 数组本身不支持分组——一手源码核对
 * `getOptionsFromChildren`，`optionList` 分支直接平铺成单个无标题组）。 */
export interface SelectOptionGroup<T> {
  label: any;
  options: T[];
}

export type SelectOptionOrGroup<T> = T | SelectOptionGroup<T>;

export function isSelectOptionGroup<T>(entry: SelectOptionOrGroup<T>): entry is SelectOptionGroup<T> {
  return typeof entry === 'object' && entry !== null && 'options' in entry && Array.isArray((entry as SelectOptionGroup<T>).options);
}

/** 展平分组结构为扁平选项序列——键盘导航/filter/虚拟滚动/回显统一基于
 * 展平后的序列，分组信息只在渲染时体现为组标题分隔。 */
export function flattenSelectOptions<T>(entries: SelectOptionOrGroup<T>[]): T[] {
  return entries.flatMap((entry) => (isSelectOptionGroup(entry) ? entry.options : [entry]));
}

/** 对齐 Semi `filter` prop 语义：`false`/未设置不过滤；`true` 走内置的
 * label 大小写不敏感包含匹配；函数则完全交给调用方判断。来源：
 * `semi-foundation/select/foundation.ts` `_filterOption`（一手来源核对，
 * 见 specs 踩坑记录）。*/
export type SelectFilter = boolean | ((inputValue: string, option: SelectFilterableOption) => boolean);

/** 按 `filter` 规则过滤 optionList，纯函数、不依赖 DOM/组件实例，供
 * Adapter 层在 input 变化时直接调用。`label` 非字符串时（如传入自定义
 * ReactNode/JSX）一律转字符串再比较，与 Semi `option.label.toString()`
 * 行为对齐。*/
export function filterSelectOptions<T extends SelectFilterableOption>(
  options: T[],
  inputValue: string,
  filter: SelectFilter | undefined,
): T[] {
  if (!filter) return options;
  if (typeof filter === 'function') {
    return options.filter((option) => filter(inputValue, option));
  }
  const input = inputValue.toLowerCase();
  return options.filter((option) => String(option.label ?? option.value).toLowerCase().includes(input));
}

/**
 * Select 的受控/非受控值管理，单选/多选两种模式共用一个 Foundation：
 * - 单选：选中即替换整个 value，并关闭下拉（由 Adapter 侧调用 Popover 的
 *   hide，Foundation 本身不感知显隐，职责单一）。
 * - 多选：value 是数组，selectValue 处理增删（类似 CheckboxGroupFoundation.
 *   toggleValue），选中后不自动关闭下拉（对齐 Semi 多选交互）。
 *
 * 显隐状态完全交给内部包装的 Popover（TooltipFoundation）管理，这里不重复
 * 造轮子——这也是 Select 复用 Popover 浮层定位基础设施的核心体现。
 */
export class SelectFoundation extends Foundation<SelectState> {
  handleSearch(input: string, onSearch?: (input: string) => void): void {
    this.setState({ searchInput: input });
    onSearch?.(input);
  }

  /** 选中/清空/关闭面板后重置搜索框——对齐 Semi「选中候选项后清空搜索输入」行为。 */
  resetSearch(): void {
    this.setState({ searchInput: '' });
  }

  selectSingle(
    itemValue: SelectValue,
    isControlled: boolean,
    onChange?: (value: SelectValue) => void,
    onSelect?: (value: SelectValue) => void,
  ): void {
    if (!isControlled) {
      this.setState({ value: itemValue });
    }
    onChange?.(itemValue);
    onSelect?.(itemValue);
  }

  /**
   * `max` 对齐 Semi：仅在"新增选中"（非取消选中）且已达上限时才拦截，
   * 通过 `onExceed` 通知调用方，不触发 onChange/state 变更。取消选中永远
   * 允许（否则用户会卡在无法减少选中项的状态）。
   */
  selectMultiple(
    itemValue: SelectValue,
    isControlled: boolean,
    onChange?: (value: SelectValue[]) => void,
    options?: { max?: number; onExceed?: () => void; onSelect?: (value: SelectValue) => void; onDeselect?: (value: SelectValue) => void },
  ): void {
    const { value } = this.getState();
    const current = Array.isArray(value) ? value : [];
    const exists = current.includes(itemValue);

    if (!exists && options?.max !== undefined && current.length >= options.max) {
      options.onExceed?.();
      return;
    }

    const next = exists ? current.filter((v) => v !== itemValue) : [...current, itemValue];

    if (!isControlled) {
      this.setState({ value: next });
    }
    onChange?.(next);
    if (exists) {
      options?.onDeselect?.(itemValue);
    } else {
      options?.onSelect?.(itemValue);
    }
  }

  removeMultipleValue(
    itemValue: SelectValue,
    isControlled: boolean,
    onChange?: (value: SelectValue[]) => void,
    onDeselect?: (value: SelectValue) => void,
  ): void {
    const { value } = this.getState();
    const current = Array.isArray(value) ? value : [];
    const next = current.filter((v) => v !== itemValue);

    if (!isControlled) {
      this.setState({ value: next });
    }
    onChange?.(next);
    onDeselect?.(itemValue);
  }

  clear(multiple: boolean, isControlled: boolean, onChange?: (value: SelectValue | SelectValue[] | undefined) => void): void {
    const next = multiple ? [] : undefined;
    if (!isControlled) {
      this.setState({ value: next });
    }
    onChange?.(next);
  }

  static isSingleChecked(value: SelectValue | SelectValue[] | undefined, itemValue: SelectValue): boolean {
    return !Array.isArray(value) && value === itemValue;
  }

  static isMultipleChecked(value: SelectValue | SelectValue[] | undefined, itemValue: SelectValue): boolean {
    return Array.isArray(value) && value.includes(itemValue);
  }

  /** 多选 tag 折叠：`maxTagCount` 未设置/<=0 或已选数量未超出时不折叠，
   * 返回全部；否则截断为前 N 个可见 tag + 剩余数量（对齐 Semi
   * maxTagCount/ellipsisTrigger 折叠为 "+N" 的行为）。 */
  static resolveVisibleTags<T extends { value: SelectValue }>(
    items: T[],
    maxTagCount: number | undefined,
  ): { visible: T[]; restCount: number; rest: T[] } {
    if (!maxTagCount || maxTagCount <= 0 || items.length <= maxTagCount) {
      return { visible: items, restCount: 0, rest: [] };
    }
    return {
      visible: items.slice(0, maxTagCount),
      restCount: items.length - maxTagCount,
      rest: items.slice(maxTagCount),
    };
  }
}
