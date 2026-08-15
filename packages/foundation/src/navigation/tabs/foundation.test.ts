import { describe, it, expect, vi } from 'vitest';
import { TabsFoundation, type TabsState, type TabItemMeta } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter(initial: TabsState): Adapter<TabsState> & { _raw: () => TabsState } {
  let state = initial;
  return {
    getState: () => state,
    setState: (patch: Partial<TabsState>) => {
      state = { ...state, ...patch };
    },
    _raw: () => state,
  };
}

const PANES: TabItemMeta[] = [
  { itemKey: '1', tab: 'tight' },
  { itemKey: '2', tab: 'medium' },
  { itemKey: '3', tab: 'loose', disabled: true },
  { itemKey: '4', tab: 'array' },
];

describe('TabsFoundation.resolveDefaultActiveKey', () => {
  it('picks the first non-disabled pane', () => {
    expect(TabsFoundation.resolveDefaultActiveKey(PANES)).toBe('1');
  });

  it('falls back to the first pane when all are disabled', () => {
    const allDisabled = PANES.map((p) => ({ ...p, disabled: true }));
    expect(TabsFoundation.resolveDefaultActiveKey(allDisabled)).toBe('1');
  });

  it('returns empty string for an empty pane list', () => {
    expect(TabsFoundation.resolveDefaultActiveKey([])).toBe('');
  });
});

describe('TabsFoundation.handleTabClick', () => {
  it('uncontrolled mode: updates internal state and calls onChange', () => {
    const adapter = createMockAdapter({ activeKey: '1', panes: PANES });
    const foundation = new TabsFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleTabClick('2', false, onChange);

    expect(adapter._raw().activeKey).toBe('2');
    expect(onChange).toHaveBeenCalledWith('2');
  });

  it('controlled mode: does not mutate internal state, only calls onChange', () => {
    const adapter = createMockAdapter({ activeKey: '1', panes: PANES });
    const foundation = new TabsFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleTabClick('2', true, onChange);

    expect(adapter._raw().activeKey).toBe('1');
    expect(onChange).toHaveBeenCalledWith('2');
  });

  it('disabled pane: does not switch and does not call onChange', () => {
    const adapter = createMockAdapter({ activeKey: '1', panes: PANES });
    const foundation = new TabsFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleTabClick('3', false, onChange);

    expect(adapter._raw().activeKey).toBe('1');
    expect(onChange).not.toHaveBeenCalled();
  });

  it('clicking the already-active tab is a no-op', () => {
    const adapter = createMockAdapter({ activeKey: '1', panes: PANES });
    const foundation = new TabsFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleTabClick('1', false, onChange);

    expect(onChange).not.toHaveBeenCalled();
  });

  it('unknown itemKey is a no-op', () => {
    const adapter = createMockAdapter({ activeKey: '1', panes: PANES });
    const foundation = new TabsFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleTabClick('unknown', false, onChange);

    expect(adapter._raw().activeKey).toBe('1');
    expect(onChange).not.toHaveBeenCalled();
  });
});

describe('TabsFoundation.resolveArrowNavigation', () => {
  it('moves to the next non-disabled pane, skipping disabled ones', () => {
    const adapter = createMockAdapter({ activeKey: '2', panes: PANES });
    const foundation = new TabsFoundation(adapter);

    // 2 -> 3(disabled, 已被过滤) -> 4
    expect(foundation.resolveArrowNavigation('2', 1)).toBe('4');
  });

  it('wraps around from the last enabled pane to the first', () => {
    const adapter = createMockAdapter({ activeKey: '4', panes: PANES });
    const foundation = new TabsFoundation(adapter);

    expect(foundation.resolveArrowNavigation('4', 1)).toBe('1');
  });

  it('moves backward and wraps around from the first to the last enabled pane', () => {
    const adapter = createMockAdapter({ activeKey: '1', panes: PANES });
    const foundation = new TabsFoundation(adapter);

    expect(foundation.resolveArrowNavigation('1', -1)).toBe('4');
  });

  it('returns the current key unchanged when there are no panes', () => {
    const adapter = createMockAdapter({ activeKey: '1', panes: [] });
    const foundation = new TabsFoundation(adapter);

    expect(foundation.resolveArrowNavigation('1', 1)).toBe('1');
  });
});
