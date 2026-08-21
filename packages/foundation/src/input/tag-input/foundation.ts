import { Foundation, type Adapter } from '../../base/adapter.js';
import { arrayMove } from '../../base/sortable-drag.js';
import { splitBySeparator, type Separator } from './split.js';
import { normalizeNewTags, applyMaxCount } from './normalize.js';

export * from './split.js';
export * from './normalize.js';

export interface TagInputState {
  tagsArray: string[];
  inputValue: string;
}

export interface TagInputFoundationOptions {
  separator: Separator;
  allowDuplicates: boolean;
  max?: number;
}

export interface AddTagsResult {
  tagsArray: string[];
  added: string[];
  exceeded: string[];
}

/**
 * TagInput 状态机：分隔符拆分、去重/裁剪、增删标签、拖拽排序。移植自 Semi
 * semi-foundation/tagInput/foundation.ts 的算法思路（对齐参考实现
 * chenzy.design 已验证的设计）。受控/onChange 等回调按 lotus 惯例（对齐
 * CheckboxFoundation/TransferFoundation）作为方法参数显式传入，Foundation
 * 不持有 props 引用。
 *
 * 对 Semi 源码的主动修正/简化（均已在调研阶段核实）：
 * 1. maxTagCount 折叠的展开状态用独立的 restExpanded 布尔量（点击触发），
 *    不照搬 Semi 把展开语义隐式耦合在容器 `active` 全局态上的设计——那套
 *    设计连"点 prefix/suffix 不触发展开"这种反直觉细节都要背下来才不出错，
 *    chenzy.design 已经验证过独立开关更清晰，直接采用；
 * 2. 拖拽排序（moveTag）与其它变更方法一样遵循受控检查，不无条件写入内部
 *    state（对齐 Transfer 组件已确认的 Semi handleSortEnd 受控检查遗漏
 *    教训，这里从一开始就统一）。
 */
export class TagInputFoundation extends Foundation<TagInputState> {
  private opts: TagInputFoundationOptions;

  constructor(adapter: Adapter<TagInputState>, opts: TagInputFoundationOptions) {
    super(adapter);
    this.opts = opts;
  }

  // ===================== 输入框文本 =====================

  setInputValue(value: string): void {
    this.setState({ inputValue: value });
  }

  // ===================== 新增标签 =====================

  /** Enter 提交 / addOnBlur 提交共用：拆分 → 去重 → max 裁剪 → 写回。inputValue 始终被清空（对齐 Semi：即便全部被过滤，输入框也清空）。 */
  addTagsFromInput(isControlled: boolean): AddTagsResult | null {
    const { tagsArray, inputValue } = this.getState();
    if (inputValue === '') return null;
    const candidates = splitBySeparator(inputValue, this.opts.separator);
    const normalized = normalizeNewTags(candidates, tagsArray, this.opts.allowDuplicates);
    const { accepted, exceeded } = applyMaxCount(tagsArray.length, normalized, this.opts.max);

    this.setState({ inputValue: '' });

    if (accepted.length === 0) {
      return { tagsArray, added: [], exceeded: exceeded.length > 0 ? candidates : [] };
    }
    const next = [...tagsArray, ...accepted];
    if (!isControlled) this.setState({ tagsArray: next });
    return { tagsArray: next, added: accepted, exceeded: exceeded.length > 0 ? candidates : [] };
  }

  // ===================== 删除标签 =====================

  /** Backspace 退格：仅当 inputValue 为空且存在标签时删除最后一个。 */
  removeLastTag(isControlled: boolean): { tagsArray: string[]; removed: string; index: number } | null {
    const { tagsArray, inputValue } = this.getState();
    if (inputValue !== '' || tagsArray.length === 0) return null;
    const index = tagsArray.length - 1;
    const removed = tagsArray[index]!;
    const next = tagsArray.slice(0, index);
    if (!isControlled) this.setState({ tagsArray: next });
    return { tagsArray: next, removed, index };
  }

  /** 点击某个标签的关闭按钮移除。 */
  removeTagAt(index: number, isControlled: boolean): { tagsArray: string[]; removed: string } | null {
    const { tagsArray } = this.getState();
    if (index < 0 || index >= tagsArray.length) return null;
    const removed = tagsArray[index]!;
    const next = tagsArray.filter((_, i) => i !== index);
    if (!isControlled) this.setState({ tagsArray: next });
    return { tagsArray: next, removed };
  }

  /** 清空全部标签（showClear 按钮）。 */
  clearAll(isControlled: boolean): string[] {
    if (!isControlled) this.setState({ tagsArray: [], inputValue: '' });
    else this.setState({ inputValue: '' });
    return [];
  }

  // ===================== 拖拽排序 =====================

  moveTag(oldIndex: number, newIndex: number, isControlled: boolean): string[] {
    const { tagsArray } = this.getState();
    const next = arrayMove(tagsArray, oldIndex, newIndex);
    if (!isControlled) this.setState({ tagsArray: next });
    return next;
  }

  // ===================== 受控同步 =====================

  syncTagsArray(tagsArray: string[]): void {
    this.setState({ tagsArray });
  }
}
