/**
 * AiChatDialogue 的消息数据结构对齐 OpenAI Response Object / Chat Completion
 * 语义（Semi semi-foundation/aiChatDialogue/foundation.ts 同源设计），与 lotus
 * 已有的 Chat 组件（纯文本 `content: string`）是两套独立数据模型——Semi 自身也是
 * 两个不相干的 Foundation 类，不做继承/复用尝试。
 */

export type AiMessageStatus = 'queued' | 'in_progress' | 'incomplete' | 'completed' | 'failed' | 'cancelled';

export type AiMessageRole = 'user' | 'assistant' | 'system' | (string & {});

/** 文本内容块（用户输入 / 模型输出文本均可用）。 */
export interface AiTextContentItem {
  type: 'input_text' | 'output_text' | 'text';
  text: string;
}

/** 图片内容块。 */
export interface AiImageContentItem {
  type: 'input_image' | 'output_image';
  image_url?: string;
  detail?: string;
}

/** 文件内容块。 */
export interface AiFileContentItem {
  type: 'input_file' | 'output_file';
  file_url?: string;
  file_name?: string;
  file_size?: number;
  file_type?: string;
}

/** 推理（thinking）内容块——AI"过程可感知"的核心承载。 */
export interface AiReasoningContentItem {
  type: 'reasoning';
  summary?: string[];
  content?: string[];
}

/** 工具调用请求块（模型发起）。 */
export interface AiToolCallContentItem {
  type: 'tool_call';
  call_id: string;
  name: string;
  arguments?: string;
  status?: 'in_progress' | 'completed' | 'failed';
  output?: string;
}

/** MCP（Model Context Protocol）工具调用块。 */
export interface AiMCPContentItem {
  type: 'mcp_call';
  call_id: string;
  server_label: string;
  name: string;
  arguments?: string;
  status?: 'in_progress' | 'completed' | 'failed';
  output?: string;
}

/** 引用/来源标注块。 */
export interface AiAnnotationContentItem {
  type: 'annotation' | 'url_citation';
  url?: string;
  title?: string;
  start_index?: number;
  end_index?: number;
}

export type AiContentItem =
  | AiTextContentItem
  | AiImageContentItem
  | AiFileContentItem
  | AiReasoningContentItem
  | AiToolCallContentItem
  | AiMCPContentItem
  | AiAnnotationContentItem;

export interface AiChatMessage {
  id: string;
  content?: string | AiContentItem[];
  output_text?: string;
  role: AiMessageRole;
  name?: string;
  createdAt?: number;
  updatedAt?: number;
  model?: string;
  status?: AiMessageStatus;
  editing?: boolean;
  like?: boolean;
  dislike?: boolean;
  [x: string]: unknown;
}

let idCounter = 0;

/** 生成一个稳定递增的消息 id（不依赖 Date.now()/Math.random()，纯计数器，测试可重复）。 */
export function nextAiMessageId(): string {
  idCounter += 1;
  return `lotus-ai-chat-msg-${idCounter}`;
}

/** 归一化消息内容为 ContentItem 数组：字符串按纯文本块包装，数组原样返回，undefined 归一化为空数组。 */
export function normalizeAiContent(content: AiChatMessage['content']): AiContentItem[] {
  if (content === undefined) return [];
  if (typeof content === 'string') return [{ type: 'text', text: content }];
  return content;
}

/** 从归一化后的 ContentItem 数组里提取拼接后的纯文本（用于复制/纯文本展示场景）。 */
export function extractPlainText(content: AiChatMessage['content']): string {
  return normalizeAiContent(content)
    .filter((item): item is AiTextContentItem => item.type === 'text' || item.type === 'input_text' || item.type === 'output_text')
    .map((item) => item.text)
    .join('');
}

export function isReasoningItem(item: AiContentItem): item is AiReasoningContentItem {
  return item.type === 'reasoning';
}

export function isToolCallItem(item: AiContentItem): item is AiToolCallContentItem {
  return item.type === 'tool_call';
}

export function isMCPCallItem(item: AiContentItem): item is AiMCPContentItem {
  return item.type === 'mcp_call';
}

export function isImageItem(item: AiContentItem): item is AiImageContentItem {
  return item.type === 'input_image' || item.type === 'output_image';
}

export function isFileItem(item: AiContentItem): item is AiFileContentItem {
  return item.type === 'input_file' || item.type === 'output_file';
}

export function isAnnotationItem(item: AiContentItem): item is AiAnnotationContentItem {
  return item.type === 'annotation' || item.type === 'url_citation';
}

/** 按 id 删除一条消息，返回新数组（不修改原数组）。 */
export function deleteAiMessageById(chats: AiChatMessage[], id: string): AiChatMessage[] {
  return chats.filter((m) => m.id !== id);
}

/** 切换一条消息的 like 状态；置为 true 时互斥清空 dislike。 */
export function toggleAiLike(chats: AiChatMessage[], id: string): AiChatMessage[] {
  return chats.map((m) => (m.id === id ? { ...m, like: !m.like, dislike: m.like ? m.dislike : false } : m));
}

/** 切换一条消息的 dislike 状态；置为 true 时互斥清空 like。 */
export function toggleAiDislike(chats: AiChatMessage[], id: string): AiChatMessage[] {
  return chats.map((m) => (m.id === id ? { ...m, dislike: !m.dislike, like: m.dislike ? m.like : false } : m));
}

/** 切换一条消息的 editing 态；置为 true 时其余消息的 editing 强制关闭（同一时刻只允许一条消息处于编辑态）。 */
export function toggleAiEditing(chats: AiChatMessage[], id: string): AiChatMessage[] {
  return chats.map((m) => ({ ...m, editing: m.id === id ? !m.editing : false }));
}

/** 提交编辑：替换目标消息的内容，退出 editing 态。 */
export function commitAiEdit(chats: AiChatMessage[], id: string, content: string): AiChatMessage[] {
  return chats.map((m) => (m.id === id ? { ...m, content, editing: false } : m));
}
