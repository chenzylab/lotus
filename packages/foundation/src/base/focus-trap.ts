/**
 * 模态类浮层（Modal/SideSheet）的 Tab 焦点陷阱纯计算逻辑，对齐 Semi
 * `packages/semi-foundation/utils/FocusHandle.ts` 的 `FocusTrapHandle` 设计思路
 * （构造时记录 `prevFocusElement`，Tab/Shift+Tab 在首尾元素处环绕）——重新设计实现，
 * 不搬运代码。DOM 查询（`getFocusableElements`）与环绕判定（`resolveTabWrapTarget`）
 * 拆成两个函数，后者是纯函数，可脱离真实 DOM 单测。
 */

const FOCUSABLE_SELECTOR = [
  'a[href]',
  'button:not([disabled])',
  'input:not([disabled])',
  'select:not([disabled])',
  'textarea:not([disabled])',
  '[tabindex]:not([tabindex="-1"])',
].join(',');

/** 查询容器内当前可聚焦的元素列表（按 DOM 顺序，不含容器自身）。 */
export function getFocusableElements(container: HTMLElement): HTMLElement[] {
  return Array.from(container.querySelectorAll<HTMLElement>(FOCUSABLE_SELECTOR)).filter(
    (el) => el.offsetParent !== null || el === document.activeElement,
  );
}

/**
 * 给定容器内的可聚焦元素列表与当前聚焦元素，计算 Tab/Shift+Tab 按下时应该把焦点
 * 环绕到哪个元素——只在"当前聚焦元素是列表首尾、且继续 Tab 会跳出容器"时返回目标元素，
 * 其余情况返回 `null` 表示不需要拦截（交给浏览器默认的 Tab 顺序处理）。
 */
export function resolveTabWrapTarget(
  focusableElements: HTMLElement[],
  activeElement: Element | null,
  shiftKey: boolean,
): HTMLElement | null {
  if (focusableElements.length === 0) return null;
  const first = focusableElements[0]!;
  const last = focusableElements[focusableElements.length - 1]!;
  if (shiftKey && activeElement === first) return last;
  if (!shiftKey && activeElement === last) return first;
  return null;
}
