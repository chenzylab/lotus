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

export type ScientificNotationConfig = boolean | { threshold?: number };

/**
 * 国家/地区代码到货币代码的映射（对齐 Semi `getCurrencyByLocaleCode`，覆盖
 * Semi 文档列出的常见 localeCode；未命中全码时按语言前缀回退，最终兜底 USD）。
 */
const LOCALE_TO_CURRENCY: Record<string, string> = {
  'zh-CN': 'CNY', 'zh-HK': 'HKD', 'zh-TW': 'TWD', 'ja-JP': 'JPY', 'ko-KR': 'KRW',
  'th-TH': 'THB', 'vi-VN': 'VND', 'ms-MY': 'MYR', 'id-ID': 'IDR', 'hi-IN': 'INR', 'ar-SA': 'SAR',
  'en-GB': 'GBP', 'de-DE': 'EUR', 'fr-FR': 'EUR', 'it-IT': 'EUR', 'es-ES': 'EUR', 'pt-PT': 'EUR', 'ru-RU': 'RUB',
  'en-US': 'USD', 'en-CA': 'CAD', 'es-MX': 'MXN',
  'pt-BR': 'BRL', 'es-AR': 'ARS',
  'en-AU': 'AUD', 'en-NZ': 'NZD',
  'en-ZA': 'ZAR', 'ar-EG': 'EGP',
};

const LANGUAGE_FALLBACK_CURRENCY: Record<string, string> = {
  en: 'USD', zh: 'CNY', es: 'EUR', fr: 'EUR', de: 'EUR', it: 'EUR', ja: 'JPY', ko: 'KRW', ru: 'RUB', ar: 'SAR',
};

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

  /** 四舍五入到指定小数位数；precision 为 undefined 时原样返回。 */
  static roundToPrecision(value: number, precision: number | undefined): number {
    if (precision === undefined) return value;
    return Number(value.toFixed(precision));
  }

  /**
   * 根据 localeCode 推导默认货币代码（对齐 Semi `getCurrencyByLocaleCode`）：
   * 先精确匹配完整 locale，未命中再按语言前缀回退，最终兜底 USD。
   */
  static resolveCurrencyByLocale(localeCode: string): string {
    if (LOCALE_TO_CURRENCY[localeCode]) return LOCALE_TO_CURRENCY[localeCode];
    const language = localeCode.split('-')[0] ?? localeCode;
    return LANGUAGE_FALLBACK_CURRENCY[language] ?? 'USD';
  }

  /**
   * 货币格式化：基于原生 `Intl.NumberFormat`（不引入第三方货币库，对齐
   * AGENTS.md「基础能力自研」——`Intl.NumberFormat` 是 JS 标准内置 API）。
   * `currency` 为字符串时直接当货币代码用；为 `true` 时按 localeCode 推导。
   */
  static formatCurrency(
    value: number,
    currency: boolean | string,
    localeCode: string,
    currencyDisplay: 'symbol' | 'code' | 'name' = 'symbol',
    showCurrencySymbol = true,
    precision?: number,
  ): string {
    const currencyCode = typeof currency === 'string' && currency.trim() !== ''
      ? currency
      : InputNumberFoundation.resolveCurrencyByLocale(localeCode);
    const formatter = new Intl.NumberFormat(localeCode, {
      style: 'currency',
      currency: currencyCode,
      currencyDisplay,
      minimumFractionDigits: precision,
      maximumFractionDigits: precision,
    });
    if (showCurrencySymbol) return formatter.format(value);
    // 不展示符号/代码/名称部分时，退化为纯数字格式化（沿用同一 locale 的分组/小数规则）。
    const plain = new Intl.NumberFormat(localeCode, {
      minimumFractionDigits: precision,
      maximumFractionDigits: precision,
    });
    return plain.format(value);
  }

  /** 科学计数法启用判断：boolean true 或非 null 的配置对象都算启用。 */
  static isScientificNotationEnabled(config: ScientificNotationConfig | undefined): boolean {
    return config === true || (typeof config === 'object' && config !== null);
  }

  /** 科学计数法阈值：配置对象里的 threshold，缺省/非法时回退 15（对齐 Semi 默认值）。 */
  static getScientificNotationThreshold(config: ScientificNotationConfig | undefined): number {
    if (typeof config === 'object' && config !== null && typeof config.threshold === 'number' && config.threshold >= 1) {
      return config.threshold;
    }
    return 15;
  }

  /** 有效数字位数达到/超过阈值时转换成科学计数法字符串，否则原样转字符串。 */
  static toScientificNotationIfNeeded(value: number, config: ScientificNotationConfig | undefined): string {
    if (!InputNumberFoundation.isScientificNotationEnabled(config) || value === 0) return String(value);
    const threshold = InputNumberFoundation.getScientificNotationThreshold(config);
    const absStr = String(Math.abs(value));
    const hasExp = /e/i.test(absStr);
    const significantDigits = absStr.replace(/[.\-+eE]/g, '').replace(/^0+/, '');
    if (!hasExp && significantDigits.length < threshold) return String(value);
    const fractionDigits = Math.max(0, Math.min(100, Math.floor(threshold) - 1));
    return value.toExponential(fractionDigits).replace(/(\.\d*?)0+e/, '$1e').replace(/\.e/, 'e');
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
   * 失焦/Enter 时的最终规整：把当前值 clamp 到边界内、按 precision 四舍五入，
   * 重新生成展示字符串（展示字符串的货币/科学计数法格式化由渲染层的
   * `resolveDisplayValue` 负责，Foundation 只管数值本身的规整）。空输入
   * 不强制变成 0——保持 undefined，对齐 Semi「不强加默认值」的语义。
   */
  handleBlur(bounds: InputNumberBounds, isControlled: boolean, onChange?: (value: number | undefined) => void, precision?: number): void {
    const { inputValue, value } = this.getState();
    this.setState({ isFocus: false });

    const parsed = value ?? InputNumberFoundation.parse(inputValue);
    if (parsed === undefined) {
      this.setState({ inputValue: '' });
      return;
    }
    const clamped = InputNumberFoundation.roundToPrecision(InputNumberFoundation.clamp(parsed, bounds), precision);
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
   * disabled 时不响应。`stepOverride` 用于 shiftStep（按住 Shift 时步进值
   * 与 bounds.step 不同）。
   */
  handleStep(
    direction: 1 | -1,
    bounds: InputNumberBounds,
    isControlled: boolean,
    disabled: boolean,
    onChange?: (value: number | undefined) => void,
    precision?: number,
    stepOverride?: number,
  ): void {
    if (disabled) return;
    const { value } = this.getState();
    const base = value ?? 0;
    const effectiveStep = stepOverride ?? bounds.step;
    const next = InputNumberFoundation.roundToPrecision(InputNumberFoundation.clamp(base + direction * effectiveStep, bounds), precision);
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
