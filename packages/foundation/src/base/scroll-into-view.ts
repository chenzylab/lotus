import { animateValue } from './animate-value.js';

/**
 * 平滑滚动到目标元素：找最近的可滚动祖先容器（scrollHeight > clientHeight
 * 且 overflow 允许滚动），用 animateValue 做数值动画插值 scrollTop。
 * 自研实现（AGENTS.md 第 0 节"基础能力自研"），不依赖
 * `scroll-into-view-if-needed` 等第三方库——只取最内层可滚动容器，
 * 不处理多层嵌套可滚动容器链路兼容，足以满足 Anchor/BackTop 场景。
 */
export function scrollIntoView(target: HTMLElement, options: { offset?: number; duration?: number } = {}): void {
  const { offset = 0, duration = 300 } = options;
  const container = findScrollableAncestor(target);
  const isWindow = container === document.documentElement || container === document.body;

  const containerTop = isWindow ? 0 : container.getBoundingClientRect().top;
  const targetTop = target.getBoundingClientRect().top;
  const currentScrollTop = isWindow ? window.pageYOffset : container.scrollTop;
  const delta = targetTop - containerTop - offset;
  const to = currentScrollTop + delta;

  animateValue({
    from: currentScrollTop,
    to,
    duration,
    easing: 'easeInOutCubic',
    onFrame: (value) => {
      if (isWindow) {
        window.scrollTo(0, value);
      } else {
        container.scrollTop = value;
      }
    },
  });
}

function findScrollableAncestor(el: HTMLElement): HTMLElement {
  let node: HTMLElement | null = el.parentElement;
  while (node && node !== document.body) {
    const style = getComputedStyle(node);
    const overflowY = style.overflowY;
    const canScroll = (overflowY === 'auto' || overflowY === 'scroll') && node.scrollHeight > node.clientHeight;
    if (canScroll) return node;
    node = node.parentElement;
  }
  return document.documentElement;
}
