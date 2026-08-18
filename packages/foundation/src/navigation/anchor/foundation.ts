export interface AnchorLinkInput {
  href: string;
  title?: any;
  children?: AnchorLinkInput[];
}

export interface FlatAnchorLink extends AnchorLinkInput {
  /** 摊平后的层级深度，0 为顶层。 */
  level: number;
}

/**
 * 多级嵌套的 links 摊平成一维数组（保留 level 信息用于渲染缩进）。
 * Ripple 无 React.cloneElement，Anchor 采用 links 数组 + 摊平渲染，
 * 而非 children 组合（同 Breadcrumb/ButtonGroup 先例的设计取舍）。
 */
export function flattenLinks(links: AnchorLinkInput[], level = 0): FlatAnchorLink[] {
  const result: FlatAnchorLink[] = [];
  for (const link of links) {
    result.push({ href: link.href, title: link.title, level });
    if (link.children?.length) {
      result.push(...flattenLinks(link.children, level + 1));
    }
  }
  return result;
}

/**
 * 根据每个 link 对应内容节点相对滚动容器顶部的位置（已减去 offsetTop），
 * 找到"最后一个 top < 0"的 link 作为当前应高亮的锚点——即用户已经滚过去
 * 的最近一个 section。全部 top >= 0（尚未滚动到任何 section）时返回
 * null。纯函数，不接触 DOM，可完全脱离浏览器单测。
 */
export function resolveActiveLink(hrefs: string[], tops: number[]): string | null {
  let lastNegativeIndex = -1;
  let lastNegativeTop = -Infinity;
  for (let i = 0; i < tops.length; i++) {
    const top = tops[i]!;
    if (top < 0 && top > lastNegativeTop) {
      lastNegativeTop = top;
      lastNegativeIndex = i;
    }
  }
  return lastNegativeIndex === -1 ? null : hrefs[lastNegativeIndex]!;
}
