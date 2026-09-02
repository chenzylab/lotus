export interface AnchorLinkInput {
  href: string;
  title?: any;
  disabled?: boolean;
  children?: AnchorLinkInput[];
}

export interface FlatAnchorLink extends AnchorLinkInput {
  /** 摊平后的层级深度，0 为顶层。 */
  level: number;
  /** 摊平前的原始祖先 href 链（不含自身），供 autoCollapse 判断"是否应该显示这一层"。 */
  ancestorHrefs: string[];
}

/**
 * 多级嵌套的 links 摊平成一维数组（保留 level/ancestorHrefs 信息用于渲染
 * 缩进和 autoCollapse 判断）。Ripple 无 React.cloneElement，links 数组是
 * 主要写法（同 Breadcrumb/ButtonGroup 先例的设计取舍）；AnchorLink 子
 * 组件的声明式写法通过 Context 双层注册实现，不复用这个摊平算法。
 */
export function flattenLinks(links: AnchorLinkInput[], level = 0, ancestorHrefs: string[] = []): FlatAnchorLink[] {
  const result: FlatAnchorLink[] = [];
  for (const link of links) {
    result.push({ href: link.href, title: link.title, disabled: link.disabled, level, ancestorHrefs });
    if (link.children?.length) {
      result.push(...flattenLinks(link.children, level + 1, [...ancestorHrefs, link.href]));
    }
  }
  return result;
}

/**
 * autoCollapse 语义：某一层级的链接是否应该显示——祖先链上没有 disabled
 * 阻断，且要么自己是顶层（无祖先），要么祖先链上存在"当前激活链接或激活
 * 链接的祖先"（对齐 Semi Link.renderChildren：activeLink === href ||
 * childMap[href].has(activeLink)）。 */
export function shouldShowInCollapse(
  link: { ancestorHrefs: string[] },
  activeLink: string | null,
  activeAncestorHrefs: string[],
): boolean {
  if (link.ancestorHrefs.length === 0) return true;
  const immediateParent = link.ancestorHrefs[link.ancestorHrefs.length - 1]!;
  return immediateParent === activeLink || activeAncestorHrefs.includes(immediateParent);
}

export interface RegisteredLinkInput {
  href: string;
  title?: any;
  disabled?: boolean;
  level: number;
  parentHref: string | null;
}

/**
 * AnchorLink 声明式写法下，把"mount 顺序无关"的注册表（Map 插入顺序取决
 * 于 Ripple 子组件先于父组件 mount 的实际时序，不代表 JSX 书写顺序）
 * 按 parentHref 重建成树形关系，再做深度优先遍历还原成 Semi 视觉上
 * "父节点后紧跟其全部子节点"的顺序，同时算出每个节点的 ancestorHrefs
 * （供 autoCollapse 复用与 links 数组写法完全相同的 shouldShowInCollapse
 * 判断逻辑，两种写法行为一致）。
 */
export function sortRegisteredLinks(links: RegisteredLinkInput[]): FlatAnchorLink[] {
  const childrenOf = new Map<string | null, RegisteredLinkInput[]>();
  for (const link of links) {
    const list = childrenOf.get(link.parentHref) ?? [];
    list.push(link);
    childrenOf.set(link.parentHref, list);
  }

  const result: FlatAnchorLink[] = [];
  function walk(parentHref: string | null, ancestorHrefs: string[]) {
    const siblings = childrenOf.get(parentHref) ?? [];
    for (const link of siblings) {
      result.push({ href: link.href, title: link.title, disabled: link.disabled, level: link.level, ancestorHrefs });
      walk(link.href, [...ancestorHrefs, link.href]);
    }
  }
  walk(null, []);
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
