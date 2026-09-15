/**
 * TextArea autosize 高度测量：移植自业界通用的 calculateNodeHeight 思路
 * （Semi/antd 均采用同一套算法）——在隐藏影子节点里 clone 目标 textarea 的
 * 完整计算样式，测量单行高度与 scrollHeight，据此换算出 minRows/maxRows
 * 对应的像素高度区间，再用当前内容的 scrollHeight 夹在这个区间内。
 */

export interface AutosizeOption {
    minRows?: number;
    maxRows?: number;
}

let shadowTextarea: HTMLTextAreaElement | null = null;

function ensureShadow(): HTMLTextAreaElement {
    if (shadowTextarea) return shadowTextarea;
    const el = document.createElement('textarea');
    el.setAttribute('aria-hidden', 'true');
    el.style.position = 'fixed';
    el.style.top = '-999999px';
    el.style.left = '0';
    el.style.height = '0';
    el.style.visibility = 'hidden';
    el.style.overflow = 'hidden';
    document.body.appendChild(el);
    shadowTextarea = el;
    return el;
}

function pxToNumber(value: string): number {
    if (!value) return 0;
    const match = value.match(/^\d*(\.\d*)?/);
    return match ? Number(match[0]) : 0;
}

let measureCanvasCtx: CanvasRenderingContext2D | null = null;

function ensureMeasureCtx(): CanvasRenderingContext2D | null {
    if (measureCanvasCtx) return measureCanvasCtx;
    const canvas = document.createElement('canvas');
    measureCanvasCtx = canvas.getContext('2d');
    return measureCanvasCtx;
}

/** 用 canvas.measureText 测量单行文本在给定字体下的像素宽度（对齐 Semi
 * calculateWrappedLines：`ctx.font = fontSize + ' ' + fontFamily` 后
 * `ctx.measureText(line).width`）。测不到 2d context 时返回 0（调用方
 * 兜底为 1 行，见 TextAreaFoundation.calculateWrappedLineCount）。 */
export function measureTextWidth(line: string, fontSize: string, fontFamily: string): number {
    const ctx = ensureMeasureCtx();
    if (!ctx) return 0;
    ctx.font = `${fontSize} ${fontFamily}`;
    return ctx.measureText(line).width;
}

/** 读取 textarea 的实际行高像素值；`line-height: normal` 或解析失败时按
 * `fontSize * 1.5` 兜底（对齐 Semi getTextareaLineHeightPx）。 */
export function getLineHeightPx(node: HTMLTextAreaElement): number {
    const style = window.getComputedStyle(node);
    const fontSize = parseFloat(style.fontSize) || 14;
    const lineHeightStr = style.lineHeight;
    if (!lineHeightStr || lineHeightStr === 'normal') return fontSize * 1.5;
    const parsed = parseFloat(lineHeightStr);
    return Number.isFinite(parsed) && parsed > 0 ? parsed : fontSize * 1.5;
}

export function calculateAutosizeHeight(node: HTMLTextAreaElement, value: string, option: AutosizeOption): number {
    const shadow = ensureShadow();
    const style = window.getComputedStyle(node);

    shadow.setAttribute('style', style.cssText);
    shadow.style.position = 'fixed';
    shadow.style.top = '-999999px';
    shadow.style.left = '0';
    shadow.style.height = 'auto';
    shadow.style.minHeight = '0';
    shadow.style.maxHeight = 'none';
    shadow.style.overflow = 'hidden';
    shadow.style.width = `${node.clientWidth}px`;
    shadow.value = value || ' ';

    const paddingTop = pxToNumber(style.paddingTop);
    const paddingBottom = pxToNumber(style.paddingBottom);
    const borderTop = pxToNumber(style.borderTopWidth);
    const borderBottom = pxToNumber(style.borderBottomWidth);
    const lineHeight = pxToNumber(style.lineHeight) || pxToNumber(style.fontSize) * 1.4;
    const boxSizingBorder = borderTop + borderBottom;
    const boxSizingPadding = paddingTop + paddingBottom;

    let contentHeight = shadow.scrollHeight - boxSizingPadding;

    const minRows = option.minRows ?? 1;
    const minHeight = lineHeight * minRows;
    contentHeight = Math.max(contentHeight, minHeight);

    if (option.maxRows) {
        const maxHeight = lineHeight * option.maxRows;
        contentHeight = Math.min(contentHeight, maxHeight);
    }

    return Math.ceil(contentHeight + boxSizingPadding + boxSizingBorder);
}
