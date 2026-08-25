import { isImageType } from './reference-suggestion.js';
import type { AiInputAttachment, AiInputMessageContent } from './content.js';
import type { AiChatMessage, AiContentItem } from '../ai-chat-dialogue/message.js';

/**
 * Adapter 桥：AiChatInput 的 onMessageSend 载荷 → AiChatDialogue 消息 /
 * OpenAI ChatCompletion 请求。这两个方向 Semi 官方并不提供（调研确认），是
 * chenzy.design 自建、lotus 沿用同样设计的桥接层——放在 ai-chat-input 目录
 * 而非 ai-chat-dialogue 目录，因为输入类型（MessageContent/Content[]）属于
 * AiChatInput 领域，单向依赖 dialogue 的类型定义，不反向污染 dialogue 模块。
 */

/** 附件是否应按图片处理。与渲染层共用 isImageType，避免两套判定漂移。 */
function isImageAttachment(att: AiInputAttachment): boolean {
  return isImageType(att);
}

/**
 * inputToMessage —— 把 AiChatInput 的 onMessageSend 载荷转成一条 AiChatMessage
 * （user 角色），供直接 push 进 AiChatDialogue 的 chats 展示。对齐 OpenAI
 * Response 输入消息形态：content 数组含 input_text/input_image/input_file。
 * @param opts.id 消息 id（AiChatDialogue 需唯一 id；调用方应提供，缺省 ''）
 */
export function inputToMessage(message: AiInputMessageContent, opts: { id?: string; model?: string } = {}): AiChatMessage {
  const parts: AiContentItem[] = [];

  for (const c of message.inputContents ?? []) {
    const text = typeof c.text === 'string' ? c.text : '';
    if (text.length > 0) parts.push({ type: 'input_text', text });
  }
  for (const att of message.attachments ?? []) {
    if (isImageAttachment(att)) {
      parts.push({ type: 'input_image', image_url: att.url });
    } else {
      parts.push({ type: 'input_file', file_name: att.name, file_url: att.url });
    }
  }

  const msg: AiChatMessage = { id: opts.id ?? '', role: 'user', content: parts };
  if (opts.model !== undefined) msg.model = opts.model;
  return msg;
}

/** OpenAI ChatCompletion 请求里的一条 message（user）。content 为多模态 parts。 */
export interface ChatCompletionInputMessage {
  role: 'user';
  content: Array<Record<string, unknown>>;
}

/**
 * inputToChatCompletion —— 把 onMessageSend 载荷转成 OpenAI ChatCompletion
 * 请求的 user message，content 为多模态 parts（text/image_url/file）。
 * 供直接放进 messages 数组喂 API。
 */
export function inputToChatCompletion(message: AiInputMessageContent): ChatCompletionInputMessage {
  const content: Array<Record<string, unknown>> = [];

  for (const c of message.inputContents ?? []) {
    const text = typeof c.text === 'string' ? c.text : '';
    if (text.length > 0) content.push({ type: 'text', text });
  }
  for (const att of message.attachments ?? []) {
    if (isImageAttachment(att)) {
      content.push({ type: 'image_url', image_url: { url: att.url } });
    } else {
      content.push({ type: 'file', file: { filename: att.name, file_data: att.url } });
    }
  }

  return { role: 'user', content };
}
