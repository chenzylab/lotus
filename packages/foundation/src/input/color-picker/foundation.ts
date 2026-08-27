import { Foundation, type Adapter } from '../../base/adapter.js';
import { fromHex, fromHsva, fromRgba, type ColorValue, type HsvaColor, type RgbaColor } from './convert.js';

export * from './convert.js';

export type ColorFormat = 'hex' | 'rgba' | 'hsva';

export interface ColorPickerState {
  value: ColorValue;
  format: ColorFormat;
}

export interface ColorPickerFoundationOptions {
  alpha: boolean;
}

function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max);
}

export const DEFAULT_COLOR_VALUE: ColorValue = fromHsva({ h: 176, s: 71, v: 77, a: 1 });

/**
 * ColorPicker 状态机：三态颜色值（hsva/rgba/hex）互相同步、三个可拖拽区域
 * （饱和度-明度矩形/色相条/透明度条）的像素↔颜色换算、DataPart 文本输入解析。
 * 移植自 Semi semi-foundation/colorPicker/foundation.ts 的算法思路（对齐参考
 * 实现 chenzy.design 的 ColorPicker 状态机），按 lotus Foundation/Adapter 分层
 * 重新组织——Foundation 不接触 DOM，像素坐标由 Adapter 在 mousedown/mousemove
 * 时用 getBoundingClientRect() 采样后传入。三个拖拽区域统一走同一套
 * document 级 mousemove/mouseup 监听策略（对齐 lotus Slider 已验证的模式，
 * 不采用 Semi 自身三个区域监听目标不统一的写法）。
 */
export class ColorPickerFoundation extends Foundation<ColorPickerState> {
  private opts: ColorPickerFoundationOptions;

  constructor(adapter: Adapter<ColorPickerState>, opts: ColorPickerFoundationOptions) {
    super(adapter);
    this.opts = opts;
  }

  // ===================== 整体取值 =====================

  getValue(): ColorValue {
    return this.getState().value;
  }

  setFormat(format: ColorFormat): void {
    this.setState({ format });
  }

  /** `isControlled` 为 true 时不写 `state.value`——受控模式下颜色必须完全
   * 来自外部 `value` prop，交互产生的中间结果只作为返回值供调用方拼装
   * onChange 载荷，不能直接落地到 state，否则父组件拒绝更新时 UI 会永久
   * 停留在交互产生的中间态（与 Cascader/TreeSelect/Upload/Rating 同一
   * 根因，详见 specs 踩坑 #100）。 */
  private applyHsva(hsva: HsvaColor, isControlled: boolean): ColorValue {
    const a = this.opts.alpha ? clamp(hsva.a, 0, 1) : 1;
    const value = fromHsva({ ...hsva, a });
    if (!isControlled) this.setState({ value });
    return value;
  }

  // ===================== 饱和度-明度矩形（ColorChooseArea） =====================

  /** 像素坐标（相对矩形左上角）→ {s,v}。s 由 x 决定，v 由 y 决定（顶部 v=100）。 */
  posToSaturationValue(x: number, y: number, width: number, height: number): { s: number; v: number } {
    const s = Math.round(clamp(width === 0 ? 0 : x / width, 0, 1) * 100);
    const v = Math.round(100 - clamp(height === 0 ? 0 : y / height, 0, 1) * 100);
    return { s, v };
  }

  handleSaturationValueChange(x: number, y: number, width: number, height: number, isControlled: boolean): ColorValue {
    const { s, v } = this.posToSaturationValue(x, y, width, height);
    const { hsva } = this.getState().value;
    return this.applyHsva({ ...hsva, s, v }, isControlled);
  }

  /** {s,v} → 手柄中心像素坐标（相对矩形左上角），供渲染层定位手柄使用。 */
  saturationValueToPos(s: number, v: number, width: number, height: number): { x: number; y: number } {
    return { x: (s / 100) * width, y: (1 - v / 100) * height };
  }

  // ===================== 色相条（ColorSlider） =====================

  posToHue(x: number, width: number): number {
    return Math.round(clamp(width === 0 ? 0 : x / width, 0, 1) * 360);
  }

  handleHueChange(x: number, width: number, isControlled: boolean): ColorValue {
    const h = this.posToHue(x, width);
    const { hsva } = this.getState().value;
    return this.applyHsva({ ...hsva, h }, isControlled);
  }

  hueToPos(h: number, width: number): number {
    return (clamp(h, 0, 360) / 360) * width;
  }

  // ===================== 透明度条（AlphaSlider） =====================

  posToAlpha(x: number, width: number): number {
    return Number(clamp(width === 0 ? 0 : x / width, 0, 1).toFixed(2));
  }

  handleAlphaChange(x: number, width: number, isControlled: boolean): ColorValue {
    if (!this.opts.alpha) return this.getState().value;
    const a = this.posToAlpha(x, width);
    const { hsva } = this.getState().value;
    return this.applyHsva({ ...hsva, a }, isControlled);
  }

  alphaToPos(a: number, width: number): number {
    return clamp(a, 0, 1) * width;
  }

  // ===================== DataPart 文本输入 =====================

  /** 直接写入完整 HSVA（键盘方向键场景，数值已由调用方算好）。 */
  handleHsvaInput(patch: Partial<HsvaColor>, isControlled: boolean): ColorValue {
    const { hsva } = this.getState().value;
    const next: HsvaColor = { ...hsva, ...patch };
    if (!this.opts.alpha) next.a = 1;
    return this.applyHsva(next, isControlled);
  }

  /** rgba 输入框：单个通道文本转数字，越界/非数字返回 null 不提交。 */
  handleRgbaChannelInput(channel: keyof RgbaColor, raw: string, isControlled: boolean): ColorValue | null {
    const num = Number(raw);
    if (!Number.isFinite(num)) return null;
    const max = channel === 'a' ? 1 : 255;
    if (num < 0 || num > max) return null;
    const { rgba } = this.getState().value;
    const next: RgbaColor = { ...rgba, [channel]: num };
    if (!this.opts.alpha) next.a = 1;
    const value = fromRgba(next);
    if (!isControlled) this.setState({ value });
    return value;
  }

  /** hex 输入框：整串文本解析，非法格式返回 null 不提交（允许半截输入不报错但也不提交）。 */
  handleHexInput(raw: string, isControlled: boolean): ColorValue | null {
    const value = fromHex(raw);
    if (!value) return null;
    if (!this.opts.alpha) value.rgba.a = 1;
    if (!this.opts.alpha) value.hsva.a = 1;
    if (!isControlled) this.setState({ value });
    return value;
  }

  // ===================== 受控同步 =====================

  syncValue(value: ColorValue): void {
    this.setState({ value });
  }
}
