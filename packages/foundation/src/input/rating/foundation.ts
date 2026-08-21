import { Foundation, type Adapter } from '../../base/adapter.js';

export interface RatingState {
  value: number;
  /** 当前 hover 预览值，undefined 表示无 hover（展示层回落到 value）。 */
  hoverValue: number | undefined;
  /** 清零后记录被清掉的值，防止鼠标未移动时紧接着的 hover 事件把预览"复原"回清零前的值。 */
  clearedValue: number | null;
}

export interface RatingFoundationOptions {
  count: number;
  allowHalf: boolean;
  allowClear: boolean;
}

function clampFraction(fraction: number): number {
  return Math.min(Math.max(fraction, 0), 1);
}

/**
 * 纯函数版单星填充态计算，供 .tsrx 组件在 `track()` 计算函数里直接调用——
 * 不能包一层走 `foundation.getStarFillState()`，那样内部会经
 * `this.displayValue()` → `this.getState()`（`untrack(() => state)` 包裹）
 * 取值，导致这个 track() 派生值永远不会因 state.value/hoverValue 变化重新
 * 求值（同一类踩坑此前在 Cascader 组件排查中记录过，见 spec 踩坑 #74）。
 * `display` 必须由调用方在 track() 计算函数体内直接读 `state.xxx` 传入，
 * 才能建立正确的响应式依赖。
 */
export function starFillState(display: number, index: number, allowHalf: boolean): 'empty' | 'half' | 'full' {
  const starValue = index + 1;
  if (display >= starValue) return 'full';
  if (allowHalf && display >= starValue - 0.5) return 'half';
  return 'empty';
}

/**
 * Rating 状态机：像素位置→分值换算（含半星判定）、hover 预览、点击清零、键盘环绕。
 * 移植自 Semi semi-foundation/rating/foundation.ts 的算法（对齐参考实现
 * chenzy.design 的 Rating.svelte），按 lotus Foundation/Adapter 分层重新组织——
 * Foundation 不接触 DOM，星星的宽度/位置信息由调用方算好"点击位置在该星宽度内
 * 的比例 fraction（0-1）"后传入，不在这里做 getBoundingClientRect。
 */
export class RatingFoundation extends Foundation<RatingState> {
  private opts: RatingFoundationOptions;

  constructor(adapter: Adapter<RatingState>, opts: RatingFoundationOptions) {
    super(adapter);
    this.opts = opts;
  }

  /** 第 index 颗星（0-based）+ 点击/悬停在该星宽度内的比例 → 该次操作对应的分值。 */
  getStarValue(index: number, fraction: number): number {
    const value = index + 1;
    if (!this.opts.allowHalf) return value;
    return clampFraction(fraction) < 0.5 ? value - 0.5 : value;
  }

  /** 展示层实际要渲染的值：hover 预览优先于已提交的 value。 */
  displayValue(): number {
    const { value, hoverValue } = this.getState();
    return hoverValue === undefined ? value : hoverValue;
  }

  /**
   * hover 预览：与当前 hoverValue、以及"刚清零掉的值"都不同才更新（对齐 Semi
   * clearedValue 守卫）——清零后鼠标可能仍停在同一颗星上不动，若不做这层过滤，
   * 紧跟着的 hover 事件会把预览值"复原"回清零前的值，造成清零操作视觉上像是
   * 没生效。返回 true 表示 hoverValue 确实变化了，调用方据此决定是否触发
   * onHoverChange；返回 false 时静默跳过。
   */
  handleHover(index: number, fraction: number): boolean {
    const { hoverValue, clearedValue } = this.getState();
    const nextValue = this.getStarValue(index, fraction);
    if (nextValue === hoverValue || nextValue === clearedValue) return false;
    this.setState({ hoverValue: nextValue });
    return true;
  }

  /** 鼠标移出：清空 hover 预览，回落到已提交的 value。 */
  handleLeave(): void {
    this.setState({ hoverValue: undefined });
  }

  /**
   * 点击提交：allowClear 且点击值等于当前已提交值时清零为 0，否则提交新值。
   * 清零场景额外记录 clearedValue，供后续 handleHover 的守卫使用；正常设值
   * 场景清空 clearedValue 记录。
   */
  handleClick(index: number, fraction: number): { value: number; changed: boolean } {
    const { value } = this.getState();
    const clicked = this.getStarValue(index, fraction);
    const isReset = this.opts.allowClear && clicked === value;
    const next = isReset ? 0 : clicked;
    if (isReset) {
      this.setState({ value: next, hoverValue: undefined, clearedValue: clicked });
    } else {
      this.setState({ value: next, hoverValue: undefined, clearedValue: null });
    }
    return { value: next, changed: next !== value };
  }

  /**
   * 键盘方向键：step 按 allowHalf 取 0.5/1。越界是**环绕（wrap-around）不是
   * 钳制（clamp）**——对齐 Semi 源码的真实行为：超过 count 直接归零，低于 0
   * 直接跳到 count，不是停在边界值不动。方向键之外的按键返回 null。
   */
  handleKeyDown(key: string): { value: number; changed: boolean } | null {
    const { value } = this.getState();
    const step = this.opts.allowHalf ? 0.5 : 1;
    let delta: number;
    switch (key) {
      case 'ArrowRight':
      case 'ArrowUp':
        delta = step;
        break;
      case 'ArrowLeft':
      case 'ArrowDown':
        delta = -step;
        break;
      default:
        return null;
    }
    const tempValue = value + delta;
    let next: number;
    if (tempValue > this.opts.count) next = 0;
    else if (tempValue < 0) next = this.opts.count;
    else next = tempValue;
    this.setState({ value: next, hoverValue: undefined, clearedValue: null });
    return { value: next, changed: next !== value };
  }

  /** 单颗星（含半星）应渲染成的填充态：'empty' | 'half' | 'full'，供渲染层决定 CSS class。 */
  getStarFillState(index: number): 'empty' | 'half' | 'full' {
    return starFillState(this.displayValue(), index, this.opts.allowHalf);
  }
}
