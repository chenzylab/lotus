import { Foundation, type Adapter } from '../../base/adapter.js';
import { deleteAiMessageById, toggleAiLike, toggleAiDislike, toggleAiEditing, commitAiEdit, type AiChatMessage } from './message.js';

export * from './message.js';
export * from './adapter-response.js';
export * from './adapter-streaming.js';
export * from './content-item.js';

export interface AiChatDialogueState {
  chats: AiChatMessage[];
  selecting: boolean;
  selectedIds: Set<string>;
}

/**
 * AiChatDialogue 的 Foundation：与 Semi 自身的 `DialogueFoundation` 同构
 * （轻量、chats 权威状态优先受控），不与 lotus 已有 `ChatFoundation` 共享基类
 * ——Semi 官方本身也是两个互不相干的 Foundation 类，数据模型分叉太大
 * （`ContentItem[]` 多块 vs 纯文本 `content: string`）不适合强行统一。
 * streaming/reasoning 归约逻辑完全下沉到独立纯函数（adapter-streaming.ts），
 * 不作为本类方法——它们需要在组件生命周期之外被 SSE 事件处理器增量调用。
 */
export class AiChatDialogueFoundation extends Foundation<AiChatDialogueState> {
  constructor(adapter: Adapter<AiChatDialogueState>) {
    super(adapter);
  }

  private applyChats(next: AiChatMessage[], isControlled: boolean): AiChatMessage[] {
    if (!isControlled) this.setState({ chats: next });
    return next;
  }

  syncChats(chats: AiChatMessage[]): void {
    this.setState({ chats });
  }

  handleDelete(id: string, isControlled: boolean): AiChatMessage[] {
    const { chats } = this.getState();
    return this.applyChats(deleteAiMessageById(chats, id), isControlled);
  }

  handleReset(id: string, isControlled: boolean): AiChatMessage[] {
    const { chats } = this.getState();
    return this.applyChats(
      chats.map((m) => (m.id === id ? { ...m, status: 'queued' as const } : m)),
      isControlled,
    );
  }

  handleLike(id: string, isControlled: boolean): AiChatMessage[] {
    const { chats } = this.getState();
    return this.applyChats(toggleAiLike(chats, id), isControlled);
  }

  handleDislike(id: string, isControlled: boolean): AiChatMessage[] {
    const { chats } = this.getState();
    return this.applyChats(toggleAiDislike(chats, id), isControlled);
  }

  handleToggleEditing(id: string, isControlled: boolean): AiChatMessage[] {
    const { chats } = this.getState();
    return this.applyChats(toggleAiEditing(chats, id), isControlled);
  }

  handleCommitEdit(id: string, content: string, isControlled: boolean): AiChatMessage[] {
    const { chats } = this.getState();
    return this.applyChats(commitAiEdit(chats, id, content), isControlled);
  }

  /** 点击建议提示模板：追加一条 completed 状态的用户消息（对齐 hints 语义：直接发送，不是回填输入框）。 */
  handleHintClick(hint: string, makeMessage: (content: string) => AiChatMessage, isControlled: boolean): AiChatMessage[] {
    const { chats } = this.getState();
    return this.applyChats([...chats, makeMessage(hint)], isControlled);
  }

  setSelecting(selecting: boolean): void {
    this.setState({ selecting, selectedIds: selecting ? this.getState().selectedIds : new Set() });
  }

  toggleSelected(id: string): Set<string> {
    const { selectedIds } = this.getState();
    const next = new Set(selectedIds);
    if (next.has(id)) next.delete(id);
    else next.add(id);
    this.setState({ selectedIds: next });
    return next;
  }

  selectAll(): Set<string> {
    const { chats } = this.getState();
    const next = new Set(chats.map((m) => m.id));
    this.setState({ selectedIds: next });
    return next;
  }

  deselectAll(): Set<string> {
    this.setState({ selectedIds: new Set() });
    return new Set();
  }
}
