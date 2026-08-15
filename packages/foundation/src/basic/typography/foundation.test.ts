import { describe, it, expect, vi, beforeEach } from 'vitest';
import { CopyableFoundation, EllipsisFoundation, type CopyableState, type EllipsisState } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter<S>(initial: S): Adapter<S> {
  let state = initial;
  return {
    getState: () => state,
    setState: (patch: Partial<S>) => {
      state = { ...state, ...patch };
    },
  };
}

describe('CopyableFoundation', () => {
  beforeEach(() => {
    Object.assign(navigator, { clipboard: { writeText: vi.fn().mockResolvedValue(undefined) } });
  });

  it('复制成功后 copied 变为 true 并回调 succeeded=true', async () => {
    const adapter = createMockAdapter<CopyableState>({ copied: false });
    const foundation = new CopyableFoundation(adapter);
    const onCopy = vi.fn();

    const result = await foundation.copy('hello', onCopy);

    expect(result).toBe(true);
    expect(adapter.getState().copied).toBe(true);
    expect(onCopy).toHaveBeenCalledWith(undefined, 'hello', true);
    expect(navigator.clipboard.writeText).toHaveBeenCalledWith('hello');
  });

  it('剪贴板写入失败时 copied 保持 false 并回调 succeeded=false', async () => {
    Object.assign(navigator, { clipboard: { writeText: vi.fn().mockRejectedValue(new Error('denied')) } });
    const adapter = createMockAdapter<CopyableState>({ copied: false });
    const foundation = new CopyableFoundation(adapter);
    const onCopy = vi.fn();

    const result = await foundation.copy('hello', onCopy);

    expect(result).toBe(false);
    expect(adapter.getState().copied).toBe(false);
    expect(onCopy).toHaveBeenCalledWith(undefined, 'hello', false);
  });

  it('未传入 onCopy 时不抛出异常', async () => {
    const adapter = createMockAdapter<CopyableState>({ copied: false });
    const foundation = new CopyableFoundation(adapter);

    await expect(foundation.copy('hello')).resolves.toBe(true);
  });

  it('reset 将 copied 复位为 false', () => {
    const adapter = createMockAdapter<CopyableState>({ copied: true });
    const foundation = new CopyableFoundation(adapter);

    foundation.reset();

    expect(adapter.getState().copied).toBe(false);
  });
});

describe('EllipsisFoundation.needsJsTruncate', () => {
  it('pos=middle 时需要 JS 截断', () => {
    expect(EllipsisFoundation.needsJsTruncate({ pos: 'middle' }, false)).toBe(true);
  });

  it('expandable 时需要 JS 截断', () => {
    expect(EllipsisFoundation.needsJsTruncate({ expandable: true }, false)).toBe(true);
  });

  it('suffix 非空时需要 JS 截断', () => {
    expect(EllipsisFoundation.needsJsTruncate({ suffix: '...更多' }, false)).toBe(true);
  });

  it('copyable=true 时需要 JS 截断', () => {
    expect(EllipsisFoundation.needsJsTruncate({}, true)).toBe(true);
  });

  it('默认末尾截断且不可复制时走 CSS 截断', () => {
    expect(EllipsisFoundation.needsJsTruncate({ pos: 'end', rows: 2 }, false)).toBe(false);
  });

  it('空配置时走 CSS 截断', () => {
    expect(EllipsisFoundation.needsJsTruncate({}, false)).toBe(false);
  });
});

describe('EllipsisFoundation.truncateMiddle', () => {
  it('文本长度不超过可见字符数时原样返回', () => {
    expect(EllipsisFoundation.truncateMiddle('短文本', 12)).toBe('短文本');
  });

  it('超长文本从中间截断并保留首尾各一半', () => {
    const result = EllipsisFoundation.truncateMiddle('abcdefghijklmnopqrstuvwxyz', 10);
    expect(result).toBe('abcde...vwxyz');
  });
});

describe('EllipsisFoundation.buildCandidateText', () => {
  it('keepChars<=0 时返回省略号', () => {
    expect(EllipsisFoundation.buildCandidateText('hello world', 'end', 0)).toBe('...');
  });

  it('末尾截断：保留前 keepChars 个字符 + 省略号', () => {
    expect(EllipsisFoundation.buildCandidateText('hello world', 'end', 5)).toBe('hello...');
  });

  it('中间截断：保留前后各 keepChars 个字符，中间替换为省略号', () => {
    expect(EllipsisFoundation.buildCandidateText('abcdefghij', 'middle', 3)).toBe('abc...hij');
  });

  it('自定义省略号字符串', () => {
    expect(EllipsisFoundation.buildCandidateText('hello world', 'end', 5, '…')).toBe('hello…');
  });
});

describe('EllipsisFoundation.toggleExpand', () => {
  it('切换展开态', () => {
    const adapter = createMockAdapter<EllipsisState>({ expanded: false });
    const foundation = new EllipsisFoundation(adapter);

    foundation.toggleExpand();
    expect(adapter.getState().expanded).toBe(true);

    foundation.toggleExpand();
    expect(adapter.getState().expanded).toBe(false);
  });
});
