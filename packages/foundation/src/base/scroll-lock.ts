/**
 * 模态类浮层（Modal/SideSheet）共享的 body 滚动锁定，跨组件引用计数——
 * 之前只有 SideSheet 自己实现了这套逻辑（模块级 `scrollLockCount`），
 * Modal 完全没有接入，导致 Modal 打开时背景内容仍可滚动；且因为各自持有
 * 独立的计数器，"Modal 打开 → SideSheet 打开 → Modal 关闭"这种跨组件
 * 嵌套场景下，Modal 关闭时只会按自己的计数器判断（从未增加过，直接判定
 * 可以解锁），错误地在 SideSheet 还开着的时候提前恢复了滚动。提取成
 * 共享模块后，两者共用同一个计数器，任意一个还开着都不会误解锁。
 */

let scrollLockCount = 0;
let originalBodyOverflow = '';
let originalBodyPaddingRight = '';

export function lockBodyScroll(): void {
  if (scrollLockCount === 0) {
    originalBodyOverflow = document.body.style.overflow;
    originalBodyPaddingRight = document.body.style.paddingRight;
    const scrollbarWidth = window.innerWidth - document.documentElement.clientWidth;
    document.body.style.overflow = 'hidden';
    if (scrollbarWidth > 0) document.body.style.paddingRight = `${scrollbarWidth}px`;
  }
  scrollLockCount += 1;
}

export function unlockBodyScroll(): void {
  scrollLockCount = Math.max(0, scrollLockCount - 1);
  if (scrollLockCount === 0) {
    document.body.style.overflow = originalBodyOverflow;
    document.body.style.paddingRight = originalBodyPaddingRight;
  }
}

/** 仅供测试重置模块级状态，避免测试间相互污染。 */
export function __resetScrollLockForTest(): void {
  scrollLockCount = 0;
  originalBodyOverflow = '';
  originalBodyPaddingRight = '';
}
