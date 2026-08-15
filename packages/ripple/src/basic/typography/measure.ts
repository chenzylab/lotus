import { EllipsisFoundation, type EllipsisPos } from '@lotus/foundation/basic/typography';

let shadowContainer: HTMLElement | null = null;

function ensureShadowContainer(): HTMLElement {
    if (shadowContainer) return shadowContainer;
    const el = document.createElement('div');
    el.setAttribute('aria-hidden', 'true');
    document.body.appendChild(el);
    shadowContainer = el;
    return el;
}

function styleToString(style: CSSStyleDeclaration): string {
    const names = Array.prototype.slice.call(style) as string[];
    return names.map((name) => `${name}: ${style.getPropertyValue(name)};`).join('');
}

function pxToNumber(value: string): number {
    if (!value) return 0;
    const match = value.match(/^\d*(\.\d*)?/);
    return match ? Number(match[0]) : 0;
}

export interface MeasureFixedNodes {
    /** 展开/收起按钮的真实 DOM 节点（需要一并计入可用宽高，测量后才 clone 进影子容器）。 */
    expand?: Node | null;
    /** 复制按钮的真实 DOM 节点。 */
    copy?: Node | null;
}

/**
 * 移植自 Semi `packages/semi-ui/typography/util.tsx` 的 `getRenderText`：在一个脱离视觉流的
 * 隐藏影子容器里 clone 原元素的完整计算样式，用二分查找不断调整候选文本长度，直到找到
 * 恰好不溢出 `rows` 行高度的最大文本，用于 `pos:'middle'`/`expandable`/`suffix`/`copyable`
 * 场景下的精确 JS 截断（无法用纯 CSS `text-overflow`/`line-clamp` 表达这些能力）。
 *
 * 与 Semi 版本的差异：这里不依赖 React/ReactDOM，只用原生 DOM API；`isStrong` 加粗补偿、
 * `ellipsisStr` 固定为 `...`（Semi 支持自定义但 lotus 未开放这个口子）。
 */
export function measureEllipsisText(
    originEl: HTMLElement,
    rows: number,
    content: string,
    fixedNodes: MeasureFixedNodes,
    suffix: string,
    pos: EllipsisPos,
): string {
    if (content.length === 0) return '';

    const container = ensureShadowContainer();
    const originStyle = window.getComputedStyle(originEl);
    const originCSS = styleToString(originStyle);
    const lineHeight = pxToNumber(originStyle.lineHeight);
    const maxHeight = Math.round(
        lineHeight * (rows + 1) + pxToNumber(originStyle.paddingTop) + pxToNumber(originStyle.paddingBottom),
    );

    container.setAttribute('style', originCSS);
    container.style.position = 'fixed';
    container.style.left = '0';
    if (originStyle.getPropertyValue('width') === 'auto' && originEl.offsetWidth) {
        container.style.width = `${originEl.offsetWidth}px`;
    }
    container.style.height = 'auto';
    container.style.top = '-999999px';
    container.style.zIndex = '-1000';
    container.style.textOverflow = 'clip';
    (container.style as any).webkitLineClamp = 'none';
    container.innerHTML = '';

    function inRange(): boolean {
        const widthInRange = container.scrollWidth <= container.offsetWidth;
        const heightInRange = container.scrollHeight < maxHeight;
        return rows === 1 ? widthInRange && heightInRange : heightInRange;
    }

    const contentHolder = document.createElement('span');
    const textNode = document.createTextNode(content);
    contentHolder.appendChild(textNode);
    if (suffix.length > 0) {
        contentHolder.appendChild(document.createTextNode(suffix));
    }
    container.appendChild(contentHolder);
    if (fixedNodes.copy) {
        container.appendChild(fixedNodes.copy.cloneNode(true));
    }

    function appendExpandNode(): void {
        container.innerHTML = '';
        container.appendChild(contentHolder);
        if (fixedNodes.expand) container.appendChild(fixedNodes.expand.cloneNode(true));
        if (fixedNodes.copy) container.appendChild(fixedNodes.copy.cloneNode(true));
    }

    function measureText(fullText: string, startLoc: number, endLoc: number): string {
        const midLoc = Math.floor((startLoc + endLoc) / 2);
        textNode.textContent = EllipsisFoundation.buildCandidateText(fullText, pos, midLoc);

        if (startLoc >= endLoc - 1 && endLoc > 0) {
            for (let step = endLoc; step >= startLoc; step -= 1) {
                const candidate = EllipsisFoundation.buildCandidateText(fullText, pos, step);
                textNode.textContent = candidate;
                if (inRange()) return candidate;
            }
        } else if (endLoc === 0) {
            return '...';
        }

        if (inRange()) return measureText(fullText, midLoc, endLoc);
        return measureText(fullText, startLoc, midLoc);
    }

    let result = content;
    if (!inRange()) {
        appendExpandNode();
        result = measureText(content, 0, pos === 'middle' ? Math.floor(content.length / 2) : content.length);
    }
    container.innerHTML = '';
    return result;
}
