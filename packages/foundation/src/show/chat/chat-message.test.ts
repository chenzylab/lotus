import { describe, expect, it } from 'vitest';
import {
  makeUserMessage,
  makeDividerMessage,
  deleteMessageById,
  toggleLike,
  toggleDislike,
  canSendContent,
  shouldSendOnEnter,
  nextMessageId,
  type ChatMessage,
} from './chat-message.js';

describe('nextMessageId', () => {
  it('每次调用返回不同的稳定递增 id', () => {
    const a = nextMessageId();
    const b = nextMessageId();
    expect(a).not.toBe(b);
  });
});

describe('makeUserMessage', () => {
  it('构建 role=user、status=complete 的消息', () => {
    const msg = makeUserMessage('hello', 'id-1');
    expect(msg).toEqual({ id: 'id-1', role: 'user', content: 'hello', status: 'complete', createAt: undefined });
  });
});

describe('makeDividerMessage', () => {
  it('构建 role=divider 的分隔线伪消息', () => {
    const msg = makeDividerMessage('id-2');
    expect(msg.role).toBe('divider');
    expect(msg.content).toBeUndefined();
  });
});

describe('deleteMessageById', () => {
  it('按 id 删除对应消息，不影响其它消息，返回新数组', () => {
    const chats: ChatMessage[] = [
      { id: '1', role: 'user', content: 'a' },
      { id: '2', role: 'assistant', content: 'b' },
    ];
    const next = deleteMessageById(chats, '1');
    expect(next).toEqual([{ id: '2', role: 'assistant', content: 'b' }]);
    expect(chats).toHaveLength(2);
  });

  it('id 不存在时原样返回等价数组', () => {
    const chats: ChatMessage[] = [{ id: '1', role: 'user', content: 'a' }];
    expect(deleteMessageById(chats, 'nonexistent')).toEqual(chats);
  });
});

describe('toggleLike', () => {
  it('切换 like 为 true 时互斥清空 dislike', () => {
    const chats: ChatMessage[] = [{ id: '1', role: 'assistant', dislike: true }];
    const next = toggleLike(chats, '1');
    expect(next[0]).toEqual({ id: '1', role: 'assistant', like: true, dislike: false });
  });

  it('再次调用切回 false，不影响 dislike', () => {
    const chats: ChatMessage[] = [{ id: '1', role: 'assistant', like: true, dislike: false }];
    const next = toggleLike(chats, '1');
    expect(next[0]!.like).toBe(false);
    expect(next[0]!.dislike).toBe(false);
  });

  it('不影响其它消息', () => {
    const chats: ChatMessage[] = [
      { id: '1', role: 'assistant' },
      { id: '2', role: 'assistant' },
    ];
    const next = toggleLike(chats, '1');
    expect(next[1]).toEqual(chats[1]);
  });
});

describe('toggleDislike', () => {
  it('切换 dislike 为 true 时互斥清空 like', () => {
    const chats: ChatMessage[] = [{ id: '1', role: 'assistant', like: true }];
    const next = toggleDislike(chats, '1');
    expect(next[0]).toEqual({ id: '1', role: 'assistant', like: false, dislike: true });
  });
});

describe('canSendContent', () => {
  it('canSend=false 时始终不可发送', () => {
    expect(canSendContent('hello', false)).toBe(false);
  });

  it('空白内容不可发送', () => {
    expect(canSendContent('   ', true)).toBe(false);
    expect(canSendContent('', true)).toBe(false);
  });

  it('非空白内容且 canSend=true 时可发送', () => {
    expect(canSendContent('hello', true)).toBe(true);
  });
});

describe('shouldSendOnEnter', () => {
  it("hotKey='enter' 时纯 Enter 发送，Shift+Enter 不发送", () => {
    expect(shouldSendOnEnter('enter', false)).toBe(true);
    expect(shouldSendOnEnter('enter', true)).toBe(false);
  });

  it("hotKey='shift+enter' 时 Shift+Enter 发送，纯 Enter 不发送", () => {
    expect(shouldSendOnEnter('shift+enter', true)).toBe(true);
    expect(shouldSendOnEnter('shift+enter', false)).toBe(false);
  });
});
