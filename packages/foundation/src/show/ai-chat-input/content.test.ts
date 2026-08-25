import { describe, it, expect } from 'vitest';
import { isSendHotKey, resolveCanSend, buildMessageContent, transformDocToContents, AI_INPUT_ZERO_WIDTH } from './content.js';

describe('isSendHotKey', () => {
  it('非 Enter 键恒为 false', () => {
    expect(isSendHotKey('a', false, 'enter')).toBe(false);
  });

  it('sendHotKey=enter：裸 Enter 发送，Shift+Enter 换行', () => {
    expect(isSendHotKey('Enter', false, 'enter')).toBe(true);
    expect(isSendHotKey('Enter', true, 'enter')).toBe(false);
  });

  it('sendHotKey=shift+enter：Shift+Enter 发送，裸 Enter 换行', () => {
    expect(isSendHotKey('Enter', true, 'shift+enter')).toBe(true);
    expect(isSendHotKey('Enter', false, 'shift+enter')).toBe(false);
  });
});

describe('resolveCanSend', () => {
  it('显式传入 canSend 时直接返回', () => {
    expect(resolveCanSend({ canSend: false, isEmpty: false })).toBe(false);
    expect(resolveCanSend({ canSend: true, isEmpty: true })).toBe(true);
  });

  it('未传 canSend：非空文本可发送', () => {
    expect(resolveCanSend({ isEmpty: false })).toBe(true);
  });

  it('未传 canSend：有附件即可发送', () => {
    expect(resolveCanSend({ isEmpty: true, attachments: [{ uid: 'a' }] })).toBe(true);
  });

  it('未传 canSend：空文本无附件不可发送', () => {
    expect(resolveCanSend({ isEmpty: true })).toBe(false);
  });
});

describe('buildMessageContent', () => {
  it('空字段省略，保持载荷精简', () => {
    expect(buildMessageContent({})).toEqual({});
  });

  it('非空字段全部保留', () => {
    const result = buildMessageContent({
      inputContents: [{ type: 'text', text: 'hi' }],
      attachments: [{ uid: 'a' }],
      references: [{ id: 'r1' }],
      setup: { model: 'gpt-5' },
    });
    expect(result).toEqual({
      inputContents: [{ type: 'text', text: 'hi' }],
      attachments: [{ uid: 'a' }],
      references: [{ id: 'r1' }],
      setup: { model: 'gpt-5' },
    });
  });
});

describe('transformDocToContents', () => {
  it('undefined 文档返回空数组', () => {
    expect(transformDocToContents(undefined)).toEqual([]);
  });

  it('纯文本段落归一为单个 text 块', () => {
    const doc = { type: 'doc', content: [{ type: 'paragraph', content: [{ type: 'text', text: 'hello' }] }] };
    expect(transformDocToContents(doc)).toEqual([{ type: 'text', text: 'hello' }]);
  });

  it('多段落之间插入换行并与相邻文本合并', () => {
    const doc = {
      type: 'doc',
      content: [
        { type: 'paragraph', content: [{ type: 'text', text: 'a' }] },
        { type: 'paragraph', content: [{ type: 'text', text: 'b' }] },
      ],
    };
    expect(transformDocToContents(doc)).toEqual([{ type: 'text', text: 'a\nb' }]);
  });

  it('hardBreak 转换成换行文本并与相邻文本合并', () => {
    const doc = { type: 'doc', content: [{ type: 'paragraph', content: [{ type: 'text', text: 'a' }, { type: 'hardBreak' }, { type: 'text', text: 'b' }] }] };
    expect(transformDocToContents(doc)).toEqual([{ type: 'text', text: 'a\nb' }]);
  });

  it('零宽字符文本归一为空字符串并被丢弃', () => {
    const doc = { type: 'doc', content: [{ type: 'paragraph', content: [{ type: 'text', text: AI_INPUT_ZERO_WIDTH }] }] };
    expect(transformDocToContents(doc)).toEqual([]);
  });

  it('skillSlot 保留为独立结构化对象，不与相邻文本合并', () => {
    const doc = {
      type: 'doc',
      content: [
        {
          type: 'paragraph',
          content: [
            { type: 'text', text: 'a' },
            { type: 'skillSlot', attrs: { value: 'search', label: '搜索', hasTemplate: true } },
            { type: 'text', text: 'b' },
          ],
        },
      ],
    };
    expect(transformDocToContents(doc)).toEqual([
      { type: 'text', text: 'a' },
      { type: 'skillSlot', value: 'search', label: '搜索', hasTemplate: true },
      { type: 'text', text: 'b' },
    ]);
  });

  it('selectSlot 归一为文本块', () => {
    const doc = { type: 'doc', content: [{ type: 'paragraph', content: [{ type: 'selectSlot', attrs: { value: 'option-a' } }] }] };
    expect(transformDocToContents(doc)).toEqual([{ type: 'text', text: 'option-a' }]);
  });

  it('inputSlot 空态回退到 placeholder', () => {
    const doc = { type: 'doc', content: [{ type: 'paragraph', content: [{ type: 'inputSlot', attrs: { placeholder: '请输入' }, content: [] }] }] };
    expect(transformDocToContents(doc)).toEqual([{ type: 'text', text: '请输入' }]);
  });

  it('inputSlot 有内容时使用实际文本', () => {
    const doc = { type: 'doc', content: [{ type: 'paragraph', content: [{ type: 'inputSlot', attrs: { placeholder: '请输入' }, content: [{ text: '实际值' }] }] }] };
    expect(transformDocToContents(doc)).toEqual([{ type: 'text', text: '实际值' }]);
  });

  it('未知节点类型走 transformer 兜底', () => {
    const doc = { type: 'doc', content: [{ type: 'paragraph', content: [{ type: 'customNode', attrs: { foo: 'bar' } }] }] };
    const transformer = new Map<string, (node: unknown) => any>([['customNode', (node: any) => ({ type: 'custom', foo: node.attrs.foo })]]);
    expect(transformDocToContents(doc, transformer)).toEqual([{ type: 'custom', foo: 'bar' }]);
  });

  it('未知节点类型且无 transformer 时静默跳过', () => {
    const doc = { type: 'doc', content: [{ type: 'paragraph', content: [{ type: 'unknownNode' }] }] };
    expect(transformDocToContents(doc)).toEqual([]);
  });
});
