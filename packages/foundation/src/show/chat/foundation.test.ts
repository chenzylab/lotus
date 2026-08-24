import { describe, expect, it } from 'vitest';
import { ChatFoundation, type ChatState } from './foundation.js';

function createFoundation(initial: ChatState) {
  let state = initial;
  const foundation = new ChatFoundation({
    getState: () => state,
    setState: (patch) => {
      state = { ...state, ...patch };
    },
  });
  return { foundation, getState: () => state };
}

describe('ChatFoundation', () => {
  it('handleInputChange 更新 inputValue', () => {
    const { foundation, getState } = createFoundation({ chats: [], inputValue: '' });
    foundation.handleInputChange('hello');
    expect(getState().inputValue).toBe('hello');
  });

  it('handleSend 非受控时追加用户消息并清空输入框', () => {
    const { foundation, getState } = createFoundation({ chats: [], inputValue: 'hi' });
    const next = foundation.handleSend(true, false);
    expect(next).toHaveLength(1);
    expect(next![0]).toMatchObject({ role: 'user', content: 'hi', status: 'complete' });
    expect(getState().chats).toEqual(next);
    expect(getState().inputValue).toBe('');
  });

  it('handleSend 受控时不写回内部 chats，但仍清空输入框并返回计算结果', () => {
    const { foundation, getState } = createFoundation({ chats: [], inputValue: 'hi' });
    const next = foundation.handleSend(true, true);
    expect(next).toHaveLength(1);
    expect(getState().chats).toEqual([]);
    expect(getState().inputValue).toBe('');
  });

  it('handleSend canSend=false 时不发送，返回 null，不清空输入框', () => {
    const { foundation, getState } = createFoundation({ chats: [], inputValue: 'hi' });
    const next = foundation.handleSend(false, false);
    expect(next).toBeNull();
    expect(getState().inputValue).toBe('hi');
  });

  it('handleSend 输入为空白时不发送', () => {
    const { foundation } = createFoundation({ chats: [], inputValue: '   ' });
    expect(foundation.handleSend(true, false)).toBeNull();
  });

  it('handleDelete 按 id 删除消息', () => {
    const { foundation, getState } = createFoundation({
      chats: [{ id: '1', role: 'user', content: 'a' }],
      inputValue: '',
    });
    const next = foundation.handleDelete('1', false);
    expect(next).toEqual([]);
    expect(getState().chats).toEqual([]);
  });

  it('handleLike/handleDislike 切换对应状态', () => {
    const { foundation } = createFoundation({
      chats: [{ id: '1', role: 'assistant' }],
      inputValue: '',
    });
    const afterLike = foundation.handleLike('1', false);
    expect(afterLike[0]!.like).toBe(true);
    const afterDislike = foundation.handleDislike('1', false);
    expect(afterDislike[0]!.dislike).toBe(true);
    expect(afterDislike[0]!.like).toBe(false);
  });

  it('handleClearContext 追加分隔线伪消息，不清空原有消息', () => {
    const { foundation } = createFoundation({
      chats: [{ id: '1', role: 'user', content: 'a' }],
      inputValue: '',
    });
    const next = foundation.handleClearContext(false);
    expect(next).toHaveLength(2);
    expect(next[1]!.role).toBe('divider');
  });

  it('handleHintClick 把提示文案写入 inputValue', () => {
    const { foundation, getState } = createFoundation({ chats: [], inputValue: '' });
    foundation.handleHintClick('帮我写一首诗');
    expect(getState().inputValue).toBe('帮我写一首诗');
  });

  it('shouldSendOnEnterKey 透传纯函数结果', () => {
    const { foundation } = createFoundation({ chats: [], inputValue: '' });
    expect(foundation.shouldSendOnEnterKey('enter', false)).toBe(true);
    expect(foundation.shouldSendOnEnterKey('enter', true)).toBe(false);
  });

  it('syncChats 直接覆盖 chats（受控同步用）', () => {
    const { foundation, getState } = createFoundation({ chats: [], inputValue: '' });
    const chats = [{ id: '1', role: 'user' as const, content: 'x' }];
    foundation.syncChats(chats);
    expect(getState().chats).toEqual(chats);
  });
});
