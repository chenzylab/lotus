import { describe, it, expect } from 'vitest';
import {
  normalizeAiContent,
  extractPlainText,
  isReasoningItem,
  isToolCallItem,
  isMCPCallItem,
  isImageItem,
  isFileItem,
  isAnnotationItem,
  deleteAiMessageById,
  toggleAiLike,
  toggleAiDislike,
  toggleAiEditing,
  commitAiEdit,
  nextAiMessageId,
  isAnyMessageStreaming,
  type AiChatMessage,
} from './message.js';

describe('normalizeAiContent', () => {
  it('undefined 归一化为空数组', () => {
    expect(normalizeAiContent(undefined)).toEqual([]);
  });

  it('字符串包装成单个 text 块', () => {
    expect(normalizeAiContent('hello')).toEqual([{ type: 'text', text: 'hello' }]);
  });

  it('数组原样返回', () => {
    const content = [{ type: 'text' as const, text: 'a' }];
    expect(normalizeAiContent(content)).toBe(content);
  });
});

describe('extractPlainText', () => {
  it('拼接所有文本类块', () => {
    const content: AiChatMessage['content'] = [
      { type: 'text', text: 'a' },
      { type: 'input_image', image_url: 'x' },
      { type: 'output_text', text: 'b' },
    ];
    expect(extractPlainText(content)).toBe('ab');
  });

  it('字符串 content 直接提取', () => {
    expect(extractPlainText('hello')).toBe('hello');
  });
});

describe('类型守卫', () => {
  it('isReasoningItem', () => {
    expect(isReasoningItem({ type: 'reasoning' })).toBe(true);
    expect(isReasoningItem({ type: 'text', text: '' })).toBe(false);
  });

  it('isToolCallItem / isMCPCallItem', () => {
    expect(isToolCallItem({ type: 'tool_call', call_id: '1', name: 'f' })).toBe(true);
    expect(isMCPCallItem({ type: 'mcp_call', call_id: '1', server_label: 's', name: 'f' })).toBe(true);
    expect(isToolCallItem({ type: 'mcp_call', call_id: '1', server_label: 's', name: 'f' })).toBe(false);
  });

  it('isImageItem / isFileItem', () => {
    expect(isImageItem({ type: 'input_image' })).toBe(true);
    expect(isImageItem({ type: 'output_image' })).toBe(true);
    expect(isFileItem({ type: 'input_file' })).toBe(true);
    expect(isFileItem({ type: 'input_image' })).toBe(false);
  });

  it('isAnnotationItem', () => {
    expect(isAnnotationItem({ type: 'annotation' })).toBe(true);
    expect(isAnnotationItem({ type: 'url_citation' })).toBe(true);
  });
});

describe('消息数组变换', () => {
  const chats: AiChatMessage[] = [
    { id: 'a', role: 'user', content: 'hi' },
    { id: 'b', role: 'assistant', content: 'hello' },
  ];

  it('deleteAiMessageById 按 id 移除', () => {
    expect(deleteAiMessageById(chats, 'a').map((m) => m.id)).toEqual(['b']);
  });

  it('toggleAiLike 互斥清空 dislike', () => {
    const withDislike: AiChatMessage[] = [{ id: 'a', role: 'assistant', dislike: true }];
    const next = toggleAiLike(withDislike, 'a');
    expect(next[0]!.like).toBe(true);
    expect(next[0]!.dislike).toBe(false);
  });

  it('toggleAiDislike 互斥清空 like', () => {
    const withLike: AiChatMessage[] = [{ id: 'a', role: 'assistant', like: true }];
    const next = toggleAiDislike(withLike, 'a');
    expect(next[0]!.dislike).toBe(true);
    expect(next[0]!.like).toBe(false);
  });

  it('toggleAiEditing 只允许一条消息处于编辑态', () => {
    const next = toggleAiEditing(chats, 'a');
    expect(next.find((m) => m.id === 'a')?.editing).toBe(true);
    expect(next.find((m) => m.id === 'b')?.editing).toBe(false);
  });

  it('commitAiEdit 替换内容并退出编辑态', () => {
    const editing: AiChatMessage[] = [{ id: 'a', role: 'user', content: 'old', editing: true }];
    const next = commitAiEdit(editing, 'a', 'new');
    expect(next[0]!.content).toBe('new');
    expect(next[0]!.editing).toBe(false);
  });
});

describe('nextAiMessageId', () => {
  it('生成稳定递增且唯一的 id', () => {
    const id1 = nextAiMessageId();
    const id2 = nextAiMessageId();
    expect(id1).not.toBe(id2);
    expect(id1).toMatch(/^lotus-ai-chat-msg-\d+$/);
  });
});

describe('isAnyMessageStreaming', () => {
  it('空数组判定为 false', () => {
    expect(isAnyMessageStreaming([])).toBe(false);
  });

  it('全部消息都是 completed 时判定为 false', () => {
    const chats: AiChatMessage[] = [
      { id: 'a', role: 'user', status: 'completed' },
      { id: 'b', role: 'assistant', status: 'completed' },
    ];
    expect(isAnyMessageStreaming(chats)).toBe(false);
  });

  it('存在一条 in_progress 消息时判定为 true，即使其它消息已完成', () => {
    const chats: AiChatMessage[] = [
      { id: 'a', role: 'user', status: 'completed' },
      { id: 'b', role: 'assistant', status: 'in_progress' },
    ];
    expect(isAnyMessageStreaming(chats)).toBe(true);
  });

  it('未设置 status 的消息不算作流式中', () => {
    const chats: AiChatMessage[] = [{ id: 'a', role: 'user' }];
    expect(isAnyMessageStreaming(chats)).toBe(false);
  });
});
