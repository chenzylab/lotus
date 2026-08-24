/**
 * Chat（基础版）消息数据结构与纯函数变换。参照 Semi Design
 * semi-foundation/chat/foundation.ts 的 Message 接口裁剪：本阶段
 * （specs/phases/phase-5-global-media-tools.spec.md）明确只做"消息列表
 * 渲染 + 输入框的基础壳层"，AI 流式响应/思考过程/打字机效果属于 Phase 6
 * AiChatDialogue 范畴，此处不涉及——Semi 本身对"流式"也只是浅层回调钩子，
 * 没有真实的 SSE/增量渲染基础设施，基础版与 Semi Chat 实质对等。
 *
 * content 本阶段只做纯文本字符串（Semi 支持 Content[] 多模态数组，留待
 * 后续评估是否需要，不在本次臆造）。
 */

export type ChatRole = 'user' | 'assistant' | 'system' | 'divider';
export type ChatMessageStatus = 'loading' | 'complete' | 'error';

export interface ChatMessage {
  id: string;
  role: ChatRole;
  name?: string;
  content?: string;
  createAt?: number;
  status?: ChatMessageStatus;
  like?: boolean;
  dislike?: boolean;
}

let idCounter = 0;

/** 生成一个稳定递增的消息 id（不依赖 Date.now()/Math.random()，纯计数器，测试可重复）。 */
export function nextMessageId(): string {
  idCounter += 1;
  return `lotus-chat-msg-${idCounter}`;
}

/** 构建一条用户发出的消息（role 固定 user，status 固定 complete）。 */
export function makeUserMessage(content: string, id: string, createAt?: number): ChatMessage {
  return { id, role: 'user', content, status: 'complete', createAt };
}

/** 构建一条分隔线伪消息（对齐 Semi clearContext：追加 divider 而非清空数组）。 */
export function makeDividerMessage(id: string, createAt?: number): ChatMessage {
  return { id, role: 'divider', createAt };
}

/** 按 id 删除一条消息，返回新数组（不修改原数组）。 */
export function deleteMessageById(chats: ChatMessage[], id: string): ChatMessage[] {
  return chats.filter((m) => m.id !== id);
}

/** 切换一条消息的 like 状态；置为 true 时互斥清空 dislike（对齐通行点赞/点踩互斥语义）。 */
export function toggleLike(chats: ChatMessage[], id: string): ChatMessage[] {
  return chats.map((m) => (m.id === id ? { ...m, like: !m.like, dislike: m.like ? m.dislike : false } : m));
}

/** 切换一条消息的 dislike 状态；置为 true 时互斥清空 like。 */
export function toggleDislike(chats: ChatMessage[], id: string): ChatMessage[] {
  return chats.map((m) => (m.id === id ? { ...m, dislike: !m.dislike, like: m.dislike ? m.like : false } : m));
}

/** 是否应该允许发送：非空白输入、且未被 canSend=false 显式禁止。 */
export function canSendContent(value: string, canSend: boolean): boolean {
  return canSend && value.trim().length > 0;
}

export type SendHotKey = 'enter' | 'shift+enter';

/**
 * 判断一次键盘事件是否应该触发发送（对齐 Semi sendHotKey 语义）：
 * 'enter' 模式下 Enter 直接发送、Shift+Enter 换行；
 * 'shift+enter' 模式下 Shift+Enter 发送、纯 Enter 换行。
 * IME 组合输入中的 Enter（isComposing）永远不触发发送，交由调用方在
 * 组合结束前拦截（对齐 TextArea 已有的 onEnterPress 组合输入处理）。
 */
export function shouldSendOnEnter(hotKey: SendHotKey, shiftKey: boolean): boolean {
  if (hotKey === 'enter') return !shiftKey;
  return shiftKey;
}
