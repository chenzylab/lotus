import { Foundation, type Adapter } from '../../base/adapter.js';
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
  type SendHotKey,
} from './chat-message.js';

export * from './chat-message.js';

export interface ChatState {
  chats: ChatMessage[];
  inputValue: string;
}

/**
 * Chat（基础版）状态机：chats 权威状态优先受控（对齐 Semi 完全受控模式，
 * Foundation 只计算变更结果 + 按 isControlled 决定是否落地到内部 state，
 * 与 TransferFoundation 同一惯用法）。所有具体的数组变换都委托给
 * chat-message.ts 纯函数，Foundation 本身只做状态读写和分支决策。
 */
export class ChatFoundation extends Foundation<ChatState> {
  constructor(adapter: Adapter<ChatState>) {
    super(adapter);
  }

  private applyChats(next: ChatMessage[], isControlled: boolean): ChatMessage[] {
    if (!isControlled) this.setState({ chats: next });
    return next;
  }

  handleInputChange(value: string): void {
    this.setState({ inputValue: value });
  }

  /** 发送当前输入内容：追加一条用户消息，清空输入框，返回追加后的完整数组。 */
  handleSend(canSend: boolean, isControlled: boolean): ChatMessage[] | null {
    const { chats, inputValue } = this.getState();
    if (!canSendContent(inputValue, canSend)) return null;
    const message = makeUserMessage(inputValue, nextMessageId());
    const next = [...chats, message];
    this.setState({ inputValue: '' });
    return this.applyChats(next, isControlled);
  }

  handleDelete(id: string, isControlled: boolean): ChatMessage[] {
    const { chats } = this.getState();
    return this.applyChats(deleteMessageById(chats, id), isControlled);
  }

  handleLike(id: string, isControlled: boolean): ChatMessage[] {
    const { chats } = this.getState();
    return this.applyChats(toggleLike(chats, id), isControlled);
  }

  handleDislike(id: string, isControlled: boolean): ChatMessage[] {
    const { chats } = this.getState();
    return this.applyChats(toggleDislike(chats, id), isControlled);
  }

  /** 清空上下文：追加一条分隔线伪消息（对齐 Semi clearContext，不是真的清空数组）。 */
  handleClearContext(isControlled: boolean): ChatMessage[] {
    const { chats } = this.getState();
    const next = [...chats, makeDividerMessage(nextMessageId())];
    return this.applyChats(next, isControlled);
  }

  handleHintClick(hint: string): void {
    this.setState({ inputValue: hint });
  }

  shouldSendOnEnterKey(hotKey: SendHotKey, shiftKey: boolean): boolean {
    return shouldSendOnEnter(hotKey, shiftKey);
  }

  syncChats(chats: ChatMessage[]): void {
    this.setState({ chats });
  }
}
