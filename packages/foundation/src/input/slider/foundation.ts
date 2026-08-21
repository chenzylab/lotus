import { Foundation, type Adapter } from '../../base/adapter.js';

export type SliderHandle = 'min' | 'max';
export type SliderValue = number | [number, number];

export interface RailRect {
  left: number;
  top: number;
  width: number;
  height: number;
}

export interface SliderState {
  value: SliderValue;
  /** 当前正在拖拽的手柄，false 表示未拖拽。 */
  dragging: SliderHandle | false;
  /** 当前聚焦（含拖拽/键盘）的手柄，驱动 tooltip 自动显隐，false 表示都未聚焦。 */
  focusPos: SliderHandle | false;
}

export interface SliderFoundationOptions {
  min: number;
  max: number;
  step: number;
  range: boolean;
  vertical: boolean;
  verticalReverse: boolean;
}

function decimalsOf(n: number): number {
  const s = String(n);
  const i = s.indexOf('.');
  return i < 0 ? 0 : s.length - i - 1;
}

/** 按 min(value,defaultValue,step) 的最大小数位数取整倍数，规避浮点误差（对齐 Semi outPutValue）。 */
function roundToPrecision(value: number, step: number): number {
  const decimals = decimalsOf(step);
  const multiplier = 10 ** decimals;
  return Math.round(value * multiplier) / multiplier;
}

function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max);
}

function isPair(value: SliderValue): value is [number, number] {
  return Array.isArray(value);
}

/**
 * Slider 状态机：像素↔数值换算、拖拽/键盘状态机、range 双手柄排序策略。
 * 移植自 Semi semi-foundation/slider/foundation.ts 的算法思路（对齐参考实现
 * chenzy.design 的 Slider.svelte 纯函数部分），按 lotus Foundation/Adapter
 * 分层重新组织——Foundation 不接触 DOM，轨道尺寸（RailRect）由 Adapter 在
 * pointerdown/pointermove 时用 getBoundingClientRect() 采样后传入。
 */
export class SliderFoundation extends Foundation<SliderState> {
  private opts: SliderFoundationOptions;

  constructor(adapter: Adapter<SliderState>, opts: SliderFoundationOptions) {
    super(adapter);
    this.opts = opts;
  }

  /** 步长对齐 + 边界钳制 + 浮点精度修正（对齐 Semi transPosToValue 的取整逻辑）。 */
  snapToStep(raw: number): number {
    const { min, max, step } = this.opts;
    const clamped = clamp(raw, min, max);
    if (step <= 0) return roundToPrecision(clamped, 1);
    const stepped = Math.round((clamped - min) / step) * step + min;
    return roundToPrecision(clamp(stepped, min, max), step);
  }

  /** 像素坐标 → 原始数值（未对齐步长）。vertical/verticalReverse 时坐标轴与百分比方向镜像。 */
  posToRawValue(clientX: number, clientY: number, rect: RailRect): number {
    const { min, max, vertical, verticalReverse } = this.opts;
    let percent: number;
    if (vertical) {
      const offset = clamp(clientY - rect.top, 0, rect.height);
      percent = rect.height === 0 ? 0 : offset / rect.height;
      if (!verticalReverse) percent = 1 - percent;
    } else {
      const offset = clamp(clientX - rect.left, 0, rect.width);
      percent = rect.width === 0 ? 0 : offset / rect.width;
    }
    return min + percent * (max - min);
  }

  /** 数值 → 百分比（0-100），供渲染层定位手柄/轨道使用。 */
  valueToPercent(value: number): number {
    const { min, max } = this.opts;
    if (max === min) return 0;
    return clamp(((value - min) / (max - min)) * 100, 0, 100);
  }

  /** 单值：直接返回该值；range：返回对应端点值。 */
  getHandleValue(handle: SliderHandle): number {
    const { value } = this.getState();
    if (isPair(value)) return handle === 'min' ? value[0] : value[1];
    return value;
  }

  // ===================== 拖拽状态机 =====================

  onHandleDown(handler: SliderHandle): void {
    this.setState({ dragging: handler, focusPos: handler });
  }

  /** 拖拽移动：算出新值写回 state。返回 {value,changed}，changed=false 时调用方不必再通知。 */
  onHandleMove(clientX: number, clientY: number, rect: RailRect): { value: SliderValue; changed: boolean } | null {
    const { dragging } = this.getState();
    if (!dragging) return null;
    const raw = this.posToRawValue(clientX, clientY, rect);
    const snapped = this.snapToStep(raw);
    const result = this._applyHandleValue(dragging, snapped);
    return result;
  }

  onHandleUp(): void {
    this.setState({ dragging: false });
  }

  onBlur(): void {
    this.setState({ focusPos: false });
  }

  /**
   * 点击轨道跳转：算出点击位置最近的手柄（range 模式按像素距离比较两端点），
   * 直接跳到该值。单值模式恒跳自身。
   */
  onRailClick(clientX: number, clientY: number, rect: RailRect): { value: SliderValue; changed: boolean; handler: SliderHandle } | null {
    const raw = this.posToRawValue(clientX, clientY, rect);
    const snapped = this.snapToStep(raw);
    const { value } = this.getState();
    let handler: SliderHandle = 'min';
    if (isPair(value)) {
      const distMin = Math.abs(snapped - value[0]);
      const distMax = Math.abs(snapped - value[1]);
      handler = distMax < distMin ? 'max' : 'min';
    }
    const result = this._applyHandleValue(handler, snapped);
    if (!result) return null;
    this.setState({ focusPos: handler });
    return { ...result, handler };
  }

  /**
   * 把某个手柄的新值写入 state。range 模式下对外始终保持排序（min<=max），
   * 不做"禁止交叉"硬校验——两手柄允许相遇贴住，超过对侧时按 Semi 的
   * focusPos 收缩策略把两值收拢到**静止那一端的当前值**（不是拖拽端算出的
   * 新位置）：拖 min 手柄超过 max 时，两值一起收缩到 max 原来的位置（min
   * 手柄视觉上被 max 挡住、拖不动了），反之亦然。这样收缩后的值天然落在
   * [min,max] 区间内，不需要额外钳制；不能写成"收缩到拖拽端的新位置"，
   * 那样会让 min 手柄直接把 max 手柄推着一起跑到任意位置，破坏 range 语义。
   */
  private _applyHandleValue(handler: SliderHandle, snapped: number): { value: SliderValue; changed: boolean } | null {
    const { value } = this.getState();
    if (!isPair(value)) {
      if (snapped === value) return { value, changed: false };
      this.setState({ value: snapped });
      return { value: snapped, changed: true };
    }
    const next: [number, number] = [...value];
    const idx = handler === 'min' ? 0 : 1;
    next[idx] = snapped;
    if (next[0] > next[1]) {
      if (handler === 'min') next[0] = next[1];
      else next[1] = next[0];
    }
    if (next[0] === value[0] && next[1] === value[1]) return { value, changed: false };
    this.setState({ value: next });
    return { value: next, changed: true };
  }

  // ===================== 键盘操作 =====================

  /**
   * 键盘步进（对齐 Semi handleKeyDown）：方向键 ±step，PageUp/PageDown ±10*step，
   * Home/End 跳边界。range 模式下 Home/End 对 max 手柄的"跳边界"实际是贴住
   * min 手柄（反之亦然），不是跳到全局 min/max——这是键盘路径独有的硬钳制，
   * 与拖拽路径的排序兜底是两套互补的约束实现。
   */
  handleKeyDown(key: string, handler: SliderHandle): { value: SliderValue; changed: boolean } | null {
    const { min, max, step } = this.opts;
    const { value } = this.getState();
    const current = this.getHandleValue(handler);
    const other = isPair(value) ? (handler === 'min' ? value[1] : value[0]) : undefined;

    let next: number | null = null;
    const bigStep = step * 10;

    switch (key) {
      case 'ArrowLeft':
      case 'ArrowDown':
        next = current - step;
        break;
      case 'ArrowRight':
      case 'ArrowUp':
        next = current + step;
        break;
      case 'PageDown':
        next = current - bigStep;
        break;
      case 'PageUp':
        next = current + bigStep;
        break;
      case 'Home':
        next = handler === 'min' ? min : (other ?? min);
        break;
      case 'End':
        next = handler === 'max' ? max : (other ?? max);
        break;
      default:
        return null;
    }

    next = this.snapToStep(next);
    if (isPair(value)) {
      if (handler === 'min') next = Math.min(next, value[1]);
      else next = Math.max(next, value[0]);
    }
    const result = this._applyHandleValue(handler, next);
    if (result) this.setState({ focusPos: handler });
    return result;
  }

  // ===================== marks =====================

  isMarkActive(mark: number): boolean {
    const { value } = this.getState();
    if (isPair(value)) return mark >= value[0] && mark <= value[1];
    return mark <= value;
  }
}
