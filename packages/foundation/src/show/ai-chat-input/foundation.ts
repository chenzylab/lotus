import { Foundation, type Adapter } from '../../base/adapter.js';
import { resolveCanSend, buildMessageContent, transformDocToContents, type AiInputAttachment, type AiInputContent, type AiInputReference, type AiInputMessageContent } from './content.js';
import { nextSuggestionIndex } from './reference-suggestion.js';
import { findSkillSlotInString, type AiInputSkill } from './skill.js';
import { setConfigureField, removeConfigureField, type AiInputConfigureValue } from './configure.js';

export * from './content.js';
export * from './reference-suggestion.js';
export * from './skill.js';
export * from './configure.js';
export * from './bridge.js';

export interface AiChatInputState {
  inputContents: AiInputContent[];
  references: AiInputReference[];
  attachments: AiInputAttachment[];
  currentSkill: AiInputSkill | undefined;
  suggestionActiveIndex: number;
  suggestionVisible: boolean;
  skillPanelVisible: boolean;
  templateVisible: boolean;
  configureValue: AiInputConfigureValue;
}

export function initialAiChatInputState(): AiChatInputState {
  return {
    inputContents: [],
    references: [],
    attachments: [],
    currentSkill: undefined,
    suggestionActiveIndex: -1,
    suggestionVisible: false,
    skillPanelVisible: false,
    templateVisible: false,
    configureValue: {},
  };
}

/**
 * AiChatInput 的 Foundation：整合 content.ts/reference-suggestion.ts/skill.ts/
 * configure.ts 的纯函数，管理引用/附件/建议导航/技能追踪/配置区的状态变更。
 * tiptap Editor 实例、DOM 事件、NodeView 全部下沉到渲染层——本类方法只接收
 * 已经从 DOM/编辑器提取出的原始值（如 doc JSON、HTML 字符串），不直接操作
 * tiptap API。
 */
export class AiChatInputFoundation extends Foundation<AiChatInputState> {
  constructor(adapter: Adapter<AiChatInputState>) {
    super(adapter);
  }

  /** 编辑器内容变化：归一化 doc JSON 为 Content[]，并从 HTML 反解析当前技能追踪状态。 */
  handleContentChange(json: unknown, html: string, transformer?: Map<string, (node: unknown) => AiInputContent>): AiInputContent[] {
    const inputContents = transformDocToContents(json, transformer);
    const currentSkill = findSkillSlotInString(html);
    this.setState({ inputContents, currentSkill });
    return inputContents;
  }

  addReference(reference: AiInputReference): AiInputReference[] {
    const { references } = this.getState();
    const next = [...references, reference];
    this.setState({ references: next });
    return next;
  }

  removeReference(id: string): AiInputReference[] {
    const { references } = this.getState();
    const next = references.filter((r) => r.id !== id);
    this.setState({ references: next });
    return next;
  }

  addAttachment(attachment: AiInputAttachment): AiInputAttachment[] {
    const { attachments } = this.getState();
    const next = [...attachments, attachment];
    this.setState({ attachments: next });
    return next;
  }

  removeAttachment(uid: string): AiInputAttachment[] {
    const { attachments } = this.getState();
    const next = attachments.filter((a) => a.uid !== uid);
    this.setState({ attachments: next });
    return next;
  }

  updateAttachment(uid: string, patch: Partial<AiInputAttachment>): AiInputAttachment[] {
    const { attachments } = this.getState();
    const next = attachments.map((a) => (a.uid === uid ? { ...a, ...patch } : a));
    this.setState({ attachments: next });
    return next;
  }

  setSuggestionVisible(visible: boolean): void {
    this.setState({ suggestionVisible: visible, suggestionActiveIndex: visible ? this.getState().suggestionActiveIndex : -1 });
  }

  moveSuggestionActive(len: number, dir: -1 | 1): number {
    const { suggestionActiveIndex } = this.getState();
    const next = nextSuggestionIndex(suggestionActiveIndex, len, dir);
    this.setState({ suggestionActiveIndex: next });
    return next;
  }

  setSkillPanelVisible(visible: boolean): void {
    this.setState({ skillPanelVisible: visible });
  }

  selectSkill(skill: AiInputSkill | undefined): void {
    this.setState({ currentSkill: skill, skillPanelVisible: false });
  }

  setTemplateVisible(visible: boolean): void {
    this.setState({ templateVisible: visible });
  }

  updateConfigureField(field: string, value: unknown): AiInputConfigureValue {
    const { configureValue } = this.getState();
    const next = setConfigureField(configureValue, { [field]: value });
    this.setState({ configureValue: next });
    return next;
  }

  removeConfigureFieldByName(field: string): AiInputConfigureValue {
    const { configureValue } = this.getState();
    const next = removeConfigureField(configureValue, field);
    this.setState({ configureValue: next });
    return next;
  }

  resolveCanSend(canSend: boolean | undefined): boolean {
    const { inputContents, attachments } = this.getState();
    const isEmpty = inputContents.length === 0 || inputContents.every((c) => c.type === 'text' && !c.text);
    return resolveCanSend({ canSend, isEmpty, attachments });
  }

  /** 组装发送载荷并重置输入区状态（不清空 configureValue——配置项跨消息保留，对齐 Semi 语义）。 */
  handleSend(keepSkillAfterSend: boolean): AiInputMessageContent {
    const { inputContents, attachments, references, configureValue, currentSkill } = this.getState();
    const message = buildMessageContent({ inputContents, attachments, references, setup: configureValue });
    this.setState({
      inputContents: [],
      attachments: [],
      references: [],
      currentSkill: keepSkillAfterSend ? currentSkill : undefined,
    });
    return message;
  }
}
