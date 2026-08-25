import { nextAiMessageId, type AiChatMessage, type AiContentItem, type AiMessageStatus } from './message.js';

/**
 * 非流式数据适配器：把 OpenAI Response API / Chat Completion API 的原始响应
 * 结构转换成 lotus AiChatMessage。这两个函数是纯 in/out 转换（不持有状态），
 * 与 Foundation 完全解耦——调用方在拿到完整 HTTP 响应后一次性调用，不适用
 * 于 SSE 增量场景（见 adapter-streaming.ts）。
 */

export interface OpenAiResponseOutputItem {
  id?: string;
  type: string;
  role?: string;
  status?: string;
  content?: Array<{ type: string; text?: string; [x: string]: unknown }>;
  summary?: Array<{ type: string; text?: string }>;
  call_id?: string;
  name?: string;
  arguments?: string;
  server_label?: string;
}

export interface OpenAiResponseObject {
  id?: string;
  model?: string;
  created_at?: number;
  status?: string;
  output?: OpenAiResponseOutputItem[];
  output_text?: string;
}

function mapResponseStatus(status: string | undefined): AiMessageStatus {
  switch (status) {
    case 'in_progress':
    case 'incomplete':
    case 'failed':
    case 'cancelled':
    case 'completed':
    case 'queued':
      return status;
    default:
      return 'completed';
  }
}

/** 把单个 output item 转换成 ContentItem（reasoning/message/function_call/mcp_call 均支持）。 */
function outputItemToContentItems(item: OpenAiResponseOutputItem): AiContentItem[] {
  if (item.type === 'reasoning') {
    return [{ type: 'reasoning', summary: (item.summary ?? []).map((s) => s.text ?? '') }];
  }
  if (item.type === 'function_call') {
    return [
      {
        type: 'tool_call',
        call_id: item.call_id ?? '',
        name: item.name ?? '',
        arguments: item.arguments,
        status: item.status === 'completed' ? 'completed' : item.status === 'failed' ? 'failed' : 'in_progress',
      },
    ];
  }
  if (item.type === 'mcp_call') {
    return [
      {
        type: 'mcp_call',
        call_id: item.call_id ?? '',
        server_label: item.server_label ?? '',
        name: item.name ?? '',
        arguments: item.arguments,
        status: item.status === 'completed' ? 'completed' : item.status === 'failed' ? 'failed' : 'in_progress',
      },
    ];
  }
  if (item.type === 'message' && item.content) {
    return item.content
      .filter((c) => c.type === 'output_text' || c.type === 'text')
      .map((c) => ({ type: 'output_text' as const, text: (c.text as string) ?? '' }));
  }
  return [];
}

/** 把一个完整的 Response Object 转换成一条 assistant 消息。 */
export function responseToMessage(response: OpenAiResponseObject, id?: string): AiChatMessage {
  const content: AiContentItem[] = (response.output ?? []).flatMap(outputItemToContentItems);
  return {
    id: id ?? nextAiMessageId(),
    role: 'assistant',
    content: content.length > 0 ? content : response.output_text,
    output_text: response.output_text,
    model: response.model,
    createdAt: response.created_at,
    status: mapResponseStatus(response.status),
  };
}

export interface OpenAiChatCompletionChoice {
  message?: { role?: string; content?: string | null; tool_calls?: Array<{ id: string; function: { name: string; arguments: string } }> };
  finish_reason?: string | null;
}

export interface OpenAiChatCompletionObject {
  id?: string;
  model?: string;
  created?: number;
  choices?: OpenAiChatCompletionChoice[];
}

function mapFinishReasonToStatus(finishReason: string | null | undefined): AiMessageStatus {
  if (finishReason === 'stop' || finishReason === 'tool_calls') return 'completed';
  if (finishReason === 'length') return 'incomplete';
  if (finishReason === 'content_filter') return 'failed';
  return 'completed';
}

/** 把一个完整的 Chat Completion Object 转换成一条 assistant 消息（取第一个 choice）。 */
export function chatCompletionToMessage(completion: OpenAiChatCompletionObject, id?: string): AiChatMessage {
  const choice = completion.choices?.[0];
  const message = choice?.message;
  const content: AiContentItem[] = [];

  if (message?.content) {
    content.push({ type: 'output_text', text: message.content });
  }
  for (const toolCall of message?.tool_calls ?? []) {
    content.push({
      type: 'tool_call',
      call_id: toolCall.id,
      name: toolCall.function.name,
      arguments: toolCall.function.arguments,
      status: 'completed',
    });
  }

  return {
    id: id ?? nextAiMessageId(),
    role: 'assistant',
    content: content.length > 0 ? content : undefined,
    model: completion.model,
    createdAt: completion.created,
    status: mapFinishReasonToStatus(choice?.finish_reason),
  };
}
