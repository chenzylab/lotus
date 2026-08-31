import { Foundation, type Adapter } from '../../base/adapter.js';

export interface CopyableState {
  copied: boolean;
}

/**
 * 复制状态机：点击复制后短暂进入 copied=true（用于切换按钮图标/展示 successTip），
 * 由调用方（Adapter 侧）负责在一段时间后调用 reset() 复位，Foundation 本身不依赖定时器
 * ——保持纯函数式、不持有副作用句柄，方便单测（不需要 mock setTimeout）。
 */
export class CopyableFoundation extends Foundation<CopyableState> {
  async copy(
    content: string,
    onCopy?: (event: MouseEvent | undefined, content: string, succeeded: boolean) => void,
    event?: MouseEvent,
  ): Promise<boolean> {
    let succeeded = false;
    try {
      await navigator.clipboard.writeText(content);
      succeeded = true;
    } catch {
      succeeded = false;
    }
    this.setState({ copied: succeeded });
    onCopy?.(event, content, succeeded);
    return succeeded;
  }

  reset(): void {
    this.setState({ copied: false });
  }
}

export interface EllipsisState {
  /** 展开/折叠态，仅在 expandable/collapsible 生效时有意义。 */
  expanded: boolean;
}

export type EllipsisPos = 'end' | 'middle';

export interface EllipsisConfig {
  rows?: number;
  pos?: EllipsisPos;
  suffix?: string;
  expandable?: boolean;
  collapsible?: boolean;
  expandText?: string;
  collapseText?: string;
  onExpand?: (expanded: boolean, event: MouseEvent) => void;
  /** 截断后是否用 Tooltip 展示完整原文，简化版：只支持布尔开关，不支持 Semi 的 type/opts/renderTooltip 定制。 */
  showTooltip?: boolean;
}

/**
 * 判断当前 ellipsis 配置是否需要 JS 截断（字符串层面预先截断 + 测量），而非纯 CSS
 * `-webkit-line-clamp`/`text-overflow`。与 Semi 文档 FAQ 一致的判断依据：
 * pos=middle、expandable、非空 suffix、copyable 任一命中就必须走 JS 截断
 * （因为 CSS 截断没有"中间省略""展开后插入固定后缀""复制指定内容"这些能力）。
 */
export class EllipsisFoundation extends Foundation<EllipsisState> {
  static needsJsTruncate(config: EllipsisConfig, copyable: boolean): boolean {
    return config.pos === 'middle' || !!config.expandable || !!config.suffix || copyable;
  }

  /** 单行场景下的字符串中间截断（与 Breadcrumb truncateMiddle 同思路，非精确像素测量）。 */
  static truncateMiddle(text: string, visibleChars: number): string {
    if (text.length <= visibleChars) return text;
    const half = Math.floor(visibleChars / 2);
    return `${text.slice(0, half)}...${text.slice(text.length - half)}`;
  }

  /**
   * 给定原文长度、末尾/中间截断位置，拼出候选截断文本——纯字符串运算，供 DOM 测量循环
   * （`measureEllipsisText`，见 `packages/ripple/src/basic/typography/measure.ts`）反复调用。
   * 对齐 Semi `util.tsx` 的 `getCurrentText`。
   */
  static buildCandidateText(fullText: string, pos: EllipsisPos, keepChars: number, ellipsisStr = '...'): string {
    if (keepChars <= 0) return ellipsisStr;
    if (pos === 'end') {
      return fullText.slice(0, keepChars) + ellipsisStr;
    }
    const end = fullText.length;
    return fullText.slice(0, keepChars) + ellipsisStr + fullText.slice(end - keepChars, end);
  }

  toggleExpand(): void {
    const { expanded } = this.getState();
    this.setState({ expanded: !expanded });
  }
}

export type NumeralRule = 'text' | 'numbers' | 'bytes-decimal' | 'bytes-binary' | 'percentages' | 'exponential';
export type NumeralTruncate = 'ceil' | 'floor' | 'round';

const TRUNCATE_METHODS: Record<NumeralTruncate, (value: number) => number> = {
  ceil: Math.ceil,
  floor: Math.floor,
  round: Math.round,
};

const BYTES_DECIMAL_UNITS = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
const BYTES_BINARY_UNITS = ['B', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB', 'ZiB', 'YiB'];

/** 数字前缀不允许单独出现（如 "-" 单独一段不算数字），移植自 Semi formatNumeral.ts 的 extractNumbers 正则。 */
function extractNumeralTokens(content: string): string[] {
  const reg = /(-?[0-9]*\.?[0-9]+([eE]-?[0-9]+)?)|([^-\d.]+)/g;
  return content.match(reg) ?? [];
}

function isNumeralToken(token: string): boolean {
  return !(Number.isNaN(Number(token)) || token.replace(/\s+/g, '') === '');
}

function truncatePrecision(value: number, precision: number, truncate: NumeralTruncate): string {
  const scaled = TRUNCATE_METHODS[truncate](value * 10 ** precision) / 10 ** precision;
  const parts = scaled.toString().split('.');
  if (parts.length === 1) return scaled.toFixed(precision);
  const fracLength = parts[1]!.length;
  if (fracLength < precision) return `${parts[0]}.${parts[1]}${'0'.repeat(precision - fracLength)}`;
  return scaled.toString();
}

function applyRule(value: number, rule: NumeralRule, precision: number, truncate: NumeralTruncate): string {
  switch (rule) {
    case 'bytes-decimal': {
      let v = value;
      let i = 0;
      while (v >= 1000) { v /= 1000; i++; }
      return `${truncatePrecision(v, precision, truncate)} ${BYTES_DECIMAL_UNITS[i]}`;
    }
    case 'bytes-binary': {
      let v = value;
      let i = 0;
      while (v >= 1024) { v /= 1024; i++; }
      return `${truncatePrecision(v, precision, truncate)} ${BYTES_BINARY_UNITS[i]}`;
    }
    case 'percentages':
      return `${truncatePrecision(value * 100, precision, truncate)}%`;
    case 'exponential': {
      const [mantissa, exponent] = value.toExponential(precision + 2).split('e');
      return `${truncatePrecision(Number(mantissa), precision, truncate)}e${exponent}`;
    }
    default:
      return truncatePrecision(value, precision, truncate);
  }
}

/**
 * 对齐 Semi `semi-foundation/typography/formatNumeral.ts` 的数值格式化算法（纯函数移植，
 * 非逐行翻译：Semi 是 class + DFS 遍历 children 虚拟节点树，lotus 只需要格式化单一字符串
 * ——children 遍历/递归格式化交给 Adapter 层处理，因为"虚拟 DOM 节点树"是 React 概念，
 * Ripple 没有等价结构）。`rule='text'`/`'numbers'` 不查表直接走 truncatePrecision；
 * 其余 rule 通过 applyRule 查表。
 */
export function formatNumeral(
  content: string,
  rule: NumeralRule,
  precision: number,
  truncate: NumeralTruncate,
  parser?: (value: string) => string,
): string {
  if (parser) return parser(content);
  const tokens = extractNumeralTokens(content);
  if (rule === 'text') {
    return tokens.map((t) => (isNumeralToken(t) ? truncatePrecision(Number(t), precision, truncate) : t)).join('');
  }
  if (rule === 'numbers') {
    return tokens.filter(isNumeralToken).map((t) => truncatePrecision(Number(t), precision, truncate)).join(',');
  }
  return tokens.map((t) => (isNumeralToken(t) ? applyRule(Number(t), rule, precision, truncate) : t)).join('');
}
