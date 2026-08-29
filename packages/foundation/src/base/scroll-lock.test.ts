import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { lockBodyScroll, unlockBodyScroll, __resetScrollLockForTest } from './scroll-lock.js';

function makeMockDocumentAndWindow(initialBodyOverflow = '', initialBodyPaddingRight = '') {
  const body = { style: { overflow: initialBodyOverflow, paddingRight: initialBodyPaddingRight } };
  const documentElement = { clientWidth: 1000 };
  return {
    document: { body, documentElement },
    window: { innerWidth: 1000 },
  };
}

describe('scroll-lock', () => {
  beforeEach(() => {
    __resetScrollLockForTest();
  });

  afterEach(() => {
    vi.unstubAllGlobals();
  });

  it('单次 lock：body.overflow 变为 hidden', () => {
    const { document, window } = makeMockDocumentAndWindow();
    vi.stubGlobal('document', document);
    vi.stubGlobal('window', window);

    lockBodyScroll();
    expect(document.body.style.overflow).toBe('hidden');
  });

  it('单次 unlock：body.overflow 恢复到 lock 之前的原始值', () => {
    const { document, window } = makeMockDocumentAndWindow('scroll');
    vi.stubGlobal('document', document);
    vi.stubGlobal('window', window);

    lockBodyScroll();
    unlockBodyScroll();
    expect(document.body.style.overflow).toBe('scroll');
  });

  it('引用计数：连续两次 lock 后只 unlock 一次，body 仍保持锁定（回归防护：跨组件嵌套场景，如 Modal 打开时 SideSheet 又打开，其中一个关闭不应误解锁另一个还开着的）', () => {
    const { document, window } = makeMockDocumentAndWindow();
    vi.stubGlobal('document', document);
    vi.stubGlobal('window', window);

    lockBodyScroll();
    lockBodyScroll();
    unlockBodyScroll();
    expect(document.body.style.overflow).toBe('hidden');

    unlockBodyScroll();
    expect(document.body.style.overflow).toBe('');
  });

  it('unlock 次数超过 lock 次数：计数不会变成负数，body 保持解锁状态', () => {
    const { document, window } = makeMockDocumentAndWindow();
    vi.stubGlobal('document', document);
    vi.stubGlobal('window', window);

    lockBodyScroll();
    unlockBodyScroll();
    unlockBodyScroll();
    unlockBodyScroll();
    expect(document.body.style.overflow).toBe('');

    // 计数没有变成负数：再 lock 一次应该走"从 0 开始锁定"的分支，而不是
    // 需要先 unlock 好几次才能抵消一个不存在的负数。
    lockBodyScroll();
    expect(document.body.style.overflow).toBe('hidden');
  });

  it('存在滚动条时补偿 paddingRight，避免锁定瞬间页面内容因滚动条消失而抖动', () => {
    const body = { style: { overflow: '', paddingRight: '' } };
    const documentElement = { clientWidth: 984 };
    vi.stubGlobal('document', { body, documentElement });
    vi.stubGlobal('window', { innerWidth: 1000 });

    lockBodyScroll();
    expect(body.style.paddingRight).toBe('16px');

    unlockBodyScroll();
    expect(body.style.paddingRight).toBe('');
  });

  it('无滚动条（innerWidth 等于 documentElement.clientWidth）时不添加 paddingRight', () => {
    const { document, window } = makeMockDocumentAndWindow();
    vi.stubGlobal('document', document);
    vi.stubGlobal('window', window);

    lockBodyScroll();
    expect(document.body.style.paddingRight).toBe('');
  });
});
