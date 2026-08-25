import { describe, it, expect } from 'vitest';
import { AiChatInputFoundation, initialAiChatInputState, type AiChatInputState } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter(initial: AiChatInputState): { adapter: Adapter<AiChatInputState>; getState: () => AiChatInputState } {
  let state = initial;
  return {
    adapter: {
      getState: () => state,
      setState: (patch) => { state = { ...state, ...patch }; },
    },
    getState: () => state,
  };
}

describe('AiChatInputFoundation', () => {
  it('handleContentChange 归一化 doc 并同步技能追踪状态', () => {
    const { adapter, getState } = createMockAdapter(initialAiChatInputState());
    const foundation = new AiChatInputFoundation(adapter);

    const doc = { type: 'doc', content: [{ type: 'paragraph', content: [{ type: 'text', text: 'hi' }] }] };
    const html = '<skill-slot data-value="search" data-label="搜索"></skill-slot>';
    const contents = foundation.handleContentChange(doc, html);

    expect(contents).toEqual([{ type: 'text', text: 'hi' }]);
    expect(getState().inputContents).toEqual(contents);
    expect(getState().currentSkill).toEqual({ value: 'search', label: '搜索' });
  });

  it('addReference/removeReference 增删引用', () => {
    const { adapter, getState } = createMockAdapter(initialAiChatInputState());
    const foundation = new AiChatInputFoundation(adapter);

    foundation.addReference({ id: 'r1' });
    expect(getState().references).toHaveLength(1);

    foundation.removeReference('r1');
    expect(getState().references).toHaveLength(0);
  });

  it('addAttachment/removeAttachment/updateAttachment', () => {
    const { adapter, getState } = createMockAdapter(initialAiChatInputState());
    const foundation = new AiChatInputFoundation(adapter);

    foundation.addAttachment({ uid: 'a1', status: 'uploading' });
    expect(getState().attachments).toHaveLength(1);

    foundation.updateAttachment('a1', { status: 'success', url: 'http://x' });
    expect(getState().attachments[0]).toMatchObject({ status: 'success', url: 'http://x' });

    foundation.removeAttachment('a1');
    expect(getState().attachments).toHaveLength(0);
  });

  it('setSuggestionVisible(false) 重置 activeIndex', () => {
    const { adapter, getState } = createMockAdapter({ ...initialAiChatInputState(), suggestionActiveIndex: 2, suggestionVisible: true });
    const foundation = new AiChatInputFoundation(adapter);

    foundation.setSuggestionVisible(false);

    expect(getState().suggestionVisible).toBe(false);
    expect(getState().suggestionActiveIndex).toBe(-1);
  });

  it('moveSuggestionActive 按方向环绕移动', () => {
    const { adapter, getState } = createMockAdapter(initialAiChatInputState());
    const foundation = new AiChatInputFoundation(adapter);

    const next = foundation.moveSuggestionActive(3, 1);
    expect(next).toBe(0);
    expect(getState().suggestionActiveIndex).toBe(0);
  });

  it('selectSkill 设置当前技能并关闭面板', () => {
    const { adapter, getState } = createMockAdapter({ ...initialAiChatInputState(), skillPanelVisible: true });
    const foundation = new AiChatInputFoundation(adapter);

    foundation.selectSkill({ value: 'search' });

    expect(getState().currentSkill).toEqual({ value: 'search' });
    expect(getState().skillPanelVisible).toBe(false);
  });

  it('updateConfigureField/removeConfigureFieldByName', () => {
    const { adapter, getState } = createMockAdapter(initialAiChatInputState());
    const foundation = new AiChatInputFoundation(adapter);

    foundation.updateConfigureField('model', 'gpt-5');
    expect(getState().configureValue).toEqual({ model: 'gpt-5' });

    foundation.removeConfigureFieldByName('model');
    expect(getState().configureValue).toEqual({});
  });

  it('resolveCanSend 空内容无附件时不可发送', () => {
    const { adapter } = createMockAdapter(initialAiChatInputState());
    const foundation = new AiChatInputFoundation(adapter);

    expect(foundation.resolveCanSend(undefined)).toBe(false);
  });

  it('resolveCanSend 有文本内容时可发送', () => {
    const { adapter } = createMockAdapter({ ...initialAiChatInputState(), inputContents: [{ type: 'text', text: 'hi' }] });
    const foundation = new AiChatInputFoundation(adapter);

    expect(foundation.resolveCanSend(undefined)).toBe(true);
  });

  it('handleSend 组装载荷并重置输入区状态', () => {
    const { adapter, getState } = createMockAdapter({
      ...initialAiChatInputState(),
      inputContents: [{ type: 'text', text: 'hi' }],
      attachments: [{ uid: 'a1' }],
      references: [{ id: 'r1' }],
      configureValue: { model: 'gpt-5' },
      currentSkill: { value: 'search' },
    });
    const foundation = new AiChatInputFoundation(adapter);

    const message = foundation.handleSend(false);

    expect(message).toEqual({
      inputContents: [{ type: 'text', text: 'hi' }],
      attachments: [{ uid: 'a1' }],
      references: [{ id: 'r1' }],
      setup: { model: 'gpt-5' },
    });
    expect(getState().inputContents).toEqual([]);
    expect(getState().attachments).toEqual([]);
    expect(getState().references).toEqual([]);
    expect(getState().currentSkill).toBeUndefined();
  });

  it('handleSend(keepSkillAfterSend=true) 保留当前技能', () => {
    const { adapter, getState } = createMockAdapter({ ...initialAiChatInputState(), currentSkill: { value: 'search' } });
    const foundation = new AiChatInputFoundation(adapter);

    foundation.handleSend(true);

    expect(getState().currentSkill).toEqual({ value: 'search' });
  });
});
