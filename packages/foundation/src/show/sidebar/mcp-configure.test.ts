import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import {
  MCPConfigureFoundation,
  filterMcpOptions,
  toggleMcpOptionActive,
  countActiveMcpOptions,
  type MCPConfigureState,
  type MCPOption,
} from './mcp-configure.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter(initial: MCPConfigureState): { adapter: Adapter<MCPConfigureState>; getState: () => MCPConfigureState } {
  let state = initial;
  return {
    adapter: {
      getState: () => state,
      setState: (patch) => { state = { ...state, ...patch }; },
    },
    getState: () => state,
  };
}

const INNER_OPTIONS: MCPOption[] = [
  { value: 'search', label: 'Web Search' },
  { value: 'calc', label: 'Calculator', disabled: true },
];
const CUSTOM_OPTIONS: MCPOption[] = [{ value: 'my-tool', label: 'My Tool' }];

describe('filterMcpOptions', () => {
  it('空输入返回全部选项', () => {
    expect(filterMcpOptions(INNER_OPTIONS, '')).toEqual(INNER_OPTIONS);
  });

  it('大小写不敏感的子串匹配', () => {
    expect(filterMcpOptions(INNER_OPTIONS, 'search')).toEqual([INNER_OPTIONS[0]]);
    expect(filterMcpOptions(INNER_OPTIONS, 'SEARCH')).toEqual([INNER_OPTIONS[0]]);
  });

  it('无匹配项返回空数组', () => {
    expect(filterMcpOptions(INNER_OPTIONS, 'nomatch')).toEqual([]);
  });
});

describe('toggleMcpOptionActive', () => {
  it('切换匹配 value 的 active', () => {
    const options: MCPOption[] = [{ value: 'a', active: false }, { value: 'b', active: false }];
    const next = toggleMcpOptionActive(options, 'a');
    expect(next[0]!.active).toBe(true);
    expect(next[1]!.active).toBe(false);
  });

  it('disabled 项不受影响', () => {
    const options: MCPOption[] = [{ value: 'a', active: false, disabled: true }];
    const next = toggleMcpOptionActive(options, 'a');
    expect(next[0]!.active).toBe(false);
  });

  it('不改变原数组（不可变更新）', () => {
    const options: MCPOption[] = [{ value: 'a', active: false }];
    const next = toggleMcpOptionActive(options, 'a');
    expect(next).not.toBe(options);
    expect(options[0]!.active).toBe(false);
  });
});

describe('countActiveMcpOptions', () => {
  it('统计 active 数量', () => {
    const options: MCPOption[] = [{ value: 'a', active: true }, { value: 'b', active: false }, { value: 'c', active: true }];
    expect(countActiveMcpOptions(options)).toBe(2);
  });
});

describe('MCPConfigureFoundation', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  function createFoundation(initialMode: 'inner' | 'custom' = 'inner') {
    const { adapter, getState } = createMockAdapter({ mode: initialMode, inputValue: '', showOptions: [] });
    const foundation = new MCPConfigureFoundation(adapter, {
      getOptions: () => INNER_OPTIONS,
      getCustomOptions: () => CUSTOM_OPTIONS,
    });
    return { foundation, getState };
  }

  it('refreshShowOptions 按当前 mode 展示对应选项列表', () => {
    const { foundation, getState } = createFoundation('inner');
    foundation.refreshShowOptions();
    expect(getState().showOptions).toEqual(INNER_OPTIONS);
  });

  it('handleModeChange 切到 custom 时展示自定义列表并清空搜索', () => {
    const { foundation, getState } = createFoundation('inner');
    foundation.handleModeChange('custom');
    expect(getState().mode).toBe('custom');
    expect(getState().inputValue).toBe('');
    expect(getState().showOptions).toEqual(CUSTOM_OPTIONS);
  });

  it('handleSearch 立即写入 inputValue；首次搜索是节流窗口的 leading 调用，立即生效', () => {
    const { foundation, getState } = createFoundation('inner');
    foundation.handleSearch('search');
    expect(getState().inputValue).toBe('search');
    expect(getState().showOptions).toEqual([INNER_OPTIONS[0]]);
  });

  it('连续快速搜索最终以最后一次输入为准（trailing 补偿覆盖 leading 调用的结果）', () => {
    const { foundation, getState } = createFoundation('inner');
    foundation.handleSearch('search');
    expect(getState().showOptions).toEqual([INNER_OPTIONS[0]]);

    foundation.handleSearch('nomatch');
    expect(getState().showOptions).toEqual([INNER_OPTIONS[0]]);

    vi.advanceTimersByTime(300);
    expect(getState().showOptions).toEqual([]);
  });
});
