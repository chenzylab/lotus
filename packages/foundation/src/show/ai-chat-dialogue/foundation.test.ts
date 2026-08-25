import { describe, it, expect } from 'vitest';
import { AiChatDialogueFoundation, type AiChatDialogueState } from './foundation.js';
import type { AiChatMessage } from './message.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter(initial: AiChatDialogueState): { adapter: Adapter<AiChatDialogueState>; getState: () => AiChatDialogueState } {
  let state = initial;
  return {
    adapter: {
      getState: () => state,
      setState: (patch) => { state = { ...state, ...patch }; },
    },
    getState: () => state,
  };
}

function makeMessage(id: string, overrides: Partial<AiChatMessage> = {}): AiChatMessage {
  return { id, role: 'user', content: 'hi', ...overrides };
}

describe('AiChatDialogueFoundation', () => {
  it('handleDelete 非受控时移除消息并落地 state', () => {
    const { adapter, getState } = createMockAdapter({ chats: [makeMessage('a'), makeMessage('b')], selecting: false, selectedIds: new Set() });
    const foundation = new AiChatDialogueFoundation(adapter);

    const next = foundation.handleDelete('a', false);

    expect(next.map((m) => m.id)).toEqual(['b']);
    expect(getState().chats.map((m) => m.id)).toEqual(['b']);
  });

  it('handleDelete 受控时不写回 state，只返回计算结果', () => {
    const { adapter, getState } = createMockAdapter({ chats: [makeMessage('a')], selecting: false, selectedIds: new Set() });
    const foundation = new AiChatDialogueFoundation(adapter);

    const next = foundation.handleDelete('a', true);

    expect(next).toEqual([]);
    expect(getState().chats).toHaveLength(1);
  });

  it('handleReset 把消息状态置回 queued', () => {
    const { adapter } = createMockAdapter({ chats: [makeMessage('a', { status: 'failed' })], selecting: false, selectedIds: new Set() });
    const foundation = new AiChatDialogueFoundation(adapter);

    const next = foundation.handleReset('a', false);

    expect(next[0]!.status).toBe('queued');
  });

  it('handleLike/handleDislike 互斥切换', () => {
    const { adapter } = createMockAdapter({ chats: [makeMessage('a')], selecting: false, selectedIds: new Set() });
    const foundation = new AiChatDialogueFoundation(adapter);

    let next = foundation.handleLike('a', false);
    expect(next[0]!.like).toBe(true);
    expect(next[0]!.dislike).toBe(false);

    next = foundation.handleDislike('a', false);
    expect(next[0]!.dislike).toBe(true);
    expect(next[0]!.like).toBe(false);
  });

  it('handleToggleEditing 只允许一条消息处于编辑态', () => {
    const { adapter } = createMockAdapter({ chats: [makeMessage('a'), makeMessage('b')], selecting: false, selectedIds: new Set() });
    const foundation = new AiChatDialogueFoundation(adapter);

    let next = foundation.handleToggleEditing('a', false);
    expect(next.find((m) => m.id === 'a')?.editing).toBe(true);
    expect(next.find((m) => m.id === 'b')?.editing).toBe(false);

    next = foundation.handleToggleEditing('b', false);
    expect(next.find((m) => m.id === 'a')?.editing).toBe(false);
    expect(next.find((m) => m.id === 'b')?.editing).toBe(true);
  });

  it('handleCommitEdit 替换内容并退出编辑态', () => {
    const { adapter } = createMockAdapter({ chats: [makeMessage('a', { editing: true })], selecting: false, selectedIds: new Set() });
    const foundation = new AiChatDialogueFoundation(adapter);

    const next = foundation.handleCommitEdit('a', 'new content', false);

    expect(next[0]!.content).toBe('new content');
    expect(next[0]!.editing).toBe(false);
  });

  it('handleHintClick 追加一条消息', () => {
    const { adapter } = createMockAdapter({ chats: [], selecting: false, selectedIds: new Set() });
    const foundation = new AiChatDialogueFoundation(adapter);

    const next = foundation.handleHintClick('帮我写代码', (content) => makeMessage('hint-1', { content }), false);

    expect(next).toHaveLength(1);
    expect(next[0]!.content).toBe('帮我写代码');
  });

  it('setSelecting(false) 时清空已选集合', () => {
    const { adapter, getState } = createMockAdapter({ chats: [], selecting: true, selectedIds: new Set(['a']) });
    const foundation = new AiChatDialogueFoundation(adapter);

    foundation.setSelecting(false);

    expect(getState().selecting).toBe(false);
    expect(getState().selectedIds.size).toBe(0);
  });

  it('toggleSelected 切换单条选中态', () => {
    const { adapter } = createMockAdapter({ chats: [], selecting: true, selectedIds: new Set() });
    const foundation = new AiChatDialogueFoundation(adapter);

    let selected = foundation.toggleSelected('a');
    expect(selected.has('a')).toBe(true);

    selected = foundation.toggleSelected('a');
    expect(selected.has('a')).toBe(false);
  });

  it('selectAll/deselectAll 全选与清空', () => {
    const { adapter } = createMockAdapter({ chats: [makeMessage('a'), makeMessage('b')], selecting: true, selectedIds: new Set() });
    const foundation = new AiChatDialogueFoundation(adapter);

    let selected = foundation.selectAll();
    expect(selected).toEqual(new Set(['a', 'b']));

    selected = foundation.deselectAll();
    expect(selected.size).toBe(0);
  });
});
