import { describe, it, expect, vi, beforeEach } from 'vitest';
import { CopyableFoundation, EllipsisFoundation, formatNumeral, type CopyableState, type EllipsisState } from './foundation.js';
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

describe('formatNumeral', () => {
  it('rule=numbers, truncate=ceil, precision=2：提取数字向上取整到2位小数，用逗号 join（对齐 Semi 测试用例数值）', () => {
    expect(formatNumeral('预期价格:1.555; 成本: -1; 盈利: 0.555', 'numbers', 2, 'ceil')).toBe('1.56,-1.00,0.56');
  });

  it('rule=exponential, truncate=floor, precision=2：科学计数法向下取整（对齐 Semi 测试用例数值）', () => {
    expect(formatNumeral('Total revenue: $ 1992.15', 'exponential', 2, 'floor')).toBe('Total revenue: $ 1.99e+3');
  });

  it('自定义 parser 时忽略 rule/precision/truncate，直接调用 parser', () => {
    expect(formatNumeral('Total revenue: $ 1992.15', 'exponential', 2, 'floor', (v) => v.replace(/[^\d.]/g, ''))).toBe(
      '1992.15',
    );
  });

  it('rule=text：非数字片段原样保留，数字片段按 precision 截断但不额外处理千分位', () => {
    expect(formatNumeral('共 1234.5 件商品', 'text', 1, 'round')).toBe('共 1234.5 件商品');
  });

  it('rule=bytes-decimal：按 1000 进制换算单位', () => {
    expect(formatNumeral('1500000', 'bytes-decimal', 2, 'round')).toBe('1.50 MB');
  });

  it('rule=bytes-binary：按 1024 进制换算单位', () => {
    expect(formatNumeral('1048576', 'bytes-binary', 2, 'round')).toBe('1.00 MiB');
  });

  it('rule=percentages：乘以 100 并加 % 后缀', () => {
    expect(formatNumeral('0.4567', 'percentages', 2, 'round')).toBe('45.67%');
  });

  it('precision 位数不足时补 0（truncatePrecision 尾部补零逻辑）', () => {
    expect(formatNumeral('1.5', 'numbers', 3, 'round')).toBe('1.500');
  });
});
