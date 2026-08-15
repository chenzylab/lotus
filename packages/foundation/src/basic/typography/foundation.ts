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
