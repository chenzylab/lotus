import type { AiChatMessage, AiMessageStatus } from './message.js';

/**
 * 流式数据适配器：把 OpenAI Response API / Chat Completion API 的 SSE 增量块
 * 归约成累积消息。全功能移植自 chenzy.design 已验证实现（对齐 Semi
 * streamingResponseToMessage/streamingChatCompletionToMessage 的事件类型
 * 覆盖范围）——按 sequence_number 顺序处理、缓冲无序块、MAX_GAP 容错跳过
 * 永久丢失的块，逐类型累积 output_text/refusal/reasoning/function_call/
 * mcp_call/code_interpreter 等 delta。纯函数：prevState 传入、nextState 传
 * 出，调用方（SSE 事件处理器）负责在不同调用之间持有这个状态，Foundation
 * 本身不参与这条链路。
 */

export interface ResponseStreamChunk {
  type?: string;
  sequence_number?: number;
  [key: string]: unknown;
}

export interface StreamingResponseState {
  processedSeq: Set<number>;
  outputs: Map<number, any>;
  meta: { id?: string; model?: string; status?: string; created_at?: number };
  error: { code?: string; message?: string } | null;
  buffer: Map<number, ResponseStreamChunk>;
  lastProcessedSeq: number;
}

function deepCloneChunk(obj: any): any {
  if (obj === null || typeof obj !== 'object') return obj;
  if (Array.isArray(obj)) return obj.map((item) => deepCloneChunk(item));
  const cloned: any = {};
  for (const key in obj) {
    if (Object.prototype.hasOwnProperty.call(obj, key)) cloned[key] = deepCloneChunk(obj[key]);
  }
  return cloned;
}

const MAX_GAP = 10;

function processResponseChunk(chunk: any, state: StreamingResponseState): void {
  switch (chunk.type) {
    case 'response.created': {
      const r = chunk.response;
      if (r) {
        state.meta.id = r.id ?? state.meta.id;
        state.meta.model = r.model ?? state.meta.model;
        state.meta.status = r.status ?? state.meta.status;
        state.meta.created_at = r.created_at ?? state.meta.created_at;
      }
      break;
    }
    case 'response.output_item.added': {
      const outIdx = typeof chunk.output_index === 'number' ? chunk.output_index : 0;
      if (!state.outputs.has(outIdx)) state.outputs.set(outIdx, deepCloneChunk(chunk.item ?? {}));
      break;
    }
    case 'response.output_item.done':
      state.outputs.set(chunk.output_index, deepCloneChunk(chunk.item));
      break;
    case 'response.content_part.added':
    case 'response.content_part.done': {
      const item = state.outputs.get(chunk.output_index);
      item.content = item.content ?? [];
      item.content[chunk.content_index] = deepCloneChunk(chunk.part);
      break;
    }
    case 'response.output_text.delta': {
      const item = state.outputs.get(chunk.output_index);
      item.content = item.content ?? [];
      item.content[chunk.content_index] = item.content[chunk.content_index] ?? { type: 'output_text', text: '' };
      item.content[chunk.content_index].text = (item.content[chunk.content_index].text ?? '') + (chunk.delta ?? '');
      break;
    }
    case 'response.output_text.done': {
      const item = state.outputs.get(chunk.output_index);
      item.content = item.content ?? [];
      item.content[chunk.content_index] = item.content[chunk.content_index] ?? { type: 'output_text', text: '' };
      item.content[chunk.content_index].text = chunk.text;
      break;
    }
    case 'response.output_text.annotation.added': {
      const item = state.outputs.get(chunk.output_index);
      item.content = item.content ?? [];
      item.content[chunk.content_index] = item.content[chunk.content_index] ?? { type: 'output_text', text: '', annotations: [] };
      item.content[chunk.content_index].annotations = item.content[chunk.content_index].annotations ?? [];
      item.content[chunk.content_index].annotations[chunk.annotation_index] = deepCloneChunk(chunk.annotation);
      break;
    }
    case 'response.refusal.delta': {
      const item = state.outputs.get(chunk.output_index);
      item.content = item.content ?? [];
      item.content[chunk.content_index] = item.content[chunk.content_index] ?? { type: 'refusal', refusal: '' };
      item.content[chunk.content_index].refusal = (item.content[chunk.content_index].refusal ?? '') + (chunk.delta ?? '');
      break;
    }
    case 'response.refusal.done': {
      const item = state.outputs.get(chunk.output_index);
      item.content = item.content ?? [];
      item.content[chunk.content_index] = item.content[chunk.content_index] ?? { type: 'refusal', refusal: '' };
      item.content[chunk.content_index].refusal = chunk.refusal;
      break;
    }
    case 'response.reasoning_summary_part.added':
    case 'response.reasoning_summary_part.done': {
      const item = state.outputs.get(chunk.output_index);
      item.summary = item.summary ?? [];
      item.summary[chunk.summary_index] = deepCloneChunk(chunk.part);
      break;
    }
    case 'response.reasoning_summary_text.delta': {
      const item = state.outputs.get(chunk.output_index);
      item.summary = item.summary ?? [];
      item.summary[chunk.summary_index] = item.summary[chunk.summary_index] ?? { type: 'reasoning', text: '' };
      item.summary[chunk.summary_index].text = (item.summary[chunk.summary_index].text ?? '') + (chunk.delta ?? '');
      break;
    }
    case 'response.reasoning_summary_text.done': {
      const item = state.outputs.get(chunk.output_index);
      item.summary = item.summary ?? [];
      item.summary[chunk.summary_index] = item.summary[chunk.summary_index] ?? { type: 'reasoning', text: '' };
      item.summary[chunk.summary_index].text = chunk.text;
      break;
    }
    case 'response.reasoning_text.delta': {
      const item = state.outputs.get(chunk.output_index);
      item.content = item.content ?? [];
      item.content[chunk.content_index] = item.content[chunk.content_index] ?? { type: 'reasoning', text: '' };
      item.content[chunk.content_index].text = (item.content[chunk.content_index].text ?? '') + (chunk.delta ?? '');
      break;
    }
    case 'response.reasoning_text.done': {
      const item = state.outputs.get(chunk.output_index);
      item.content = item.content ?? [];
      item.content[chunk.content_index] = item.content[chunk.content_index] ?? { type: 'reasoning', text: '' };
      item.content[chunk.content_index].text = chunk.text;
      break;
    }
    case 'response.function_call_arguments.delta': {
      const item = state.outputs.get(chunk.output_index);
      item.arguments = (item.arguments ?? '') + (chunk.delta ?? '');
      break;
    }
    case 'response.function_call_arguments.done': {
      const item = state.outputs.get(chunk.output_index);
      item.arguments = chunk.arguments;
      item.name = chunk.name;
      break;
    }
    case 'response.custom_tool_call_input.delta': {
      const item = state.outputs.get(chunk.output_index);
      item.input = (item.input ?? '') + (chunk.delta ?? '');
      break;
    }
    case 'response.custom_tool_call_input.done': {
      const item = state.outputs.get(chunk.output_index);
      item.input = chunk.input;
      break;
    }
    case 'response.mcp_call_arguments.delta': {
      const item = state.outputs.get(chunk.output_index);
      item.arguments = (item.arguments ?? '') + (chunk.delta ?? '');
      break;
    }
    case 'response.mcp_call_arguments.done': {
      const item = state.outputs.get(chunk.output_index);
      item.arguments = chunk.arguments;
      break;
    }
    case 'response.file_search_call.in_progress':
    case 'response.web_search_call.in_progress':
    case 'response.image_generation_call.in_progress':
    case 'response.mcp_call.in_progress':
    case 'response.mcp_list_tools.in_progress':
    case 'response.code_interpreter_call.in_progress': {
      const out = state.outputs.get(chunk.output_index);
      if (out) out.status = 'in_progress';
      break;
    }
    case 'response.mcp_call.failed':
    case 'response.mcp_list_tools.failed': {
      const out = state.outputs.get(chunk.output_index);
      if (out) out.status = 'failed';
      break;
    }
    case 'response.file_search_call.completed':
    case 'response.web_search_call.completed':
    case 'response.image_generation_call.completed':
    case 'response.mcp_call.completed':
    case 'response.mcp_list_tools.completed':
    case 'response.code_interpreter_call.completed': {
      const out = state.outputs.get(chunk.output_index);
      if (out) out.status = 'completed';
      break;
    }
    case 'response.code_interpreter_call_code.delta': {
      const item = state.outputs.get(chunk.output_index);
      item.code = (item.code ?? '') + (chunk.delta ?? '');
      break;
    }
    case 'response.code_interpreter_call_code.done': {
      const item = state.outputs.get(chunk.output_index);
      item.code = chunk.code;
      break;
    }
    case 'response.image_generation_call.partial_image': {
      const item = state.outputs.get(chunk.output_index);
      if (item) item.result = chunk.partial_image_b64;
      break;
    }
    case 'error':
      state.error = { code: chunk.code, message: chunk.message };
      break;
    case 'response.completed':
      state.meta.status = chunk.response?.status ?? 'completed';
      break;
    default:
      break;
  }
}

/**
 * 流式 Response 块的增量归约器（无序容错）：按 sequence_number 顺序处理、
 * 缓冲无序块、缓冲积压超过 MAX_GAP(10) 时假设中间块永久丢失并跳过继续处理。
 * @param chunks 本次到达的流式块数组
 * @param prevState 上次调用返回的 nextState（增量处理；首次传 undefined/null）
 * @returns message 为尽力而为的累积消息（in_progress/completed）；无块返回 null
 */
export function streamingResponseToMessage(
  chunks: ResponseStreamChunk[] | null | undefined,
  prevState?: StreamingResponseState | null,
): { message: AiChatMessage | null; nextState: StreamingResponseState | null } | null {
  if (!chunks?.length) return null;

  const tail = chunks[chunks.length - 1] as any;
  if (tail?.type === 'response.completed' && tail.response) {
    const { id, model, status, output, output_text, created_at } = tail.response;
    const message: AiChatMessage = { id, role: 'assistant' };
    if (output !== undefined) message.content = output;
    if (created_at !== undefined) message.createdAt = created_at;
    if (output_text !== undefined) message.output_text = output_text;
    if (model !== undefined) message.model = model;
    if (status !== undefined) message.status = status as AiMessageStatus;
    return { message, nextState: null };
  }

  const state: StreamingResponseState = prevState
    ? {
        processedSeq: new Set(prevState.processedSeq),
        outputs: new Map(prevState.outputs),
        meta: { ...prevState.meta },
        error: prevState.error ?? null,
        buffer: new Map(prevState.buffer),
        lastProcessedSeq: prevState.lastProcessedSeq ?? -1,
      }
    : {
        processedSeq: new Set<number>(),
        outputs: new Map<number, any>(),
        meta: {},
        error: null,
        buffer: new Map<number, ResponseStreamChunk>(),
        lastProcessedSeq: -1,
      };

  const unprocessed = chunks.filter((c) => {
    const seq = c?.sequence_number;
    return typeof seq !== 'number' || !state.processedSeq.has(seq);
  });
  for (const chunk of unprocessed) {
    const seq = chunk?.sequence_number;
    if (typeof seq === 'number') state.buffer.set(seq, chunk);
    else state.buffer.set(state.lastProcessedSeq + 0.5, chunk);
  }

  let nextExpected = state.lastProcessedSeq + 1;
  let processed: boolean;
  do {
    processed = false;
    const chunk = state.buffer.get(nextExpected);
    if (chunk) {
      processResponseChunk(chunk, state);
      state.processedSeq.add(nextExpected);
      state.buffer.delete(nextExpected);
      state.lastProcessedSeq = nextExpected;
      nextExpected++;
      processed = true;
    } else {
      const decimalKey = state.lastProcessedSeq + 0.5;
      const noSeqChunk = state.buffer.get(decimalKey);
      if (noSeqChunk) {
        processResponseChunk(noSeqChunk, state);
        state.buffer.delete(decimalKey);
        state.lastProcessedSeq = nextExpected;
        nextExpected++;
        processed = true;
      }
    }
  } while (processed);

  const bufferedSeqs = Array.from(state.buffer.keys())
    .filter((k) => typeof k === 'number' && k === Math.floor(k))
    .sort((a, b) => a - b);
  if (bufferedSeqs.length > MAX_GAP) {
    let lastSeq = state.lastProcessedSeq;
    for (const seq of bufferedSeqs) {
      if (seq === lastSeq + 1) {
        const chunk = state.buffer.get(seq);
        if (chunk) {
          processResponseChunk(chunk, state);
          state.processedSeq.add(seq);
          state.buffer.delete(seq);
          state.lastProcessedSeq = seq;
          lastSeq = seq;
        }
      } else break;
    }
  }

  const content = Array.from(state.outputs.values()).filter((item) => item !== null);
  const output_text = content
    .filter((p) => p?.type === 'output_text')
    .map((p) => p?.text ?? '')
    .join('');

  let message: AiChatMessage | null = null;
  if (content.length || state.meta.id) {
    message = {
      id: state.meta.id ?? '',
      role: 'assistant',
      content,
      output_text,
      status: (state.meta.status as AiMessageStatus) ?? 'in_progress',
      error: state.error ?? null,
    };
    if (state.meta.created_at !== undefined) message.createdAt = state.meta.created_at;
    if (state.meta.model !== undefined) message.model = state.meta.model;
  }

  return { message, nextState: state };
}

export interface ChatCompletionStreamChunk {
  id: string;
  choices: Array<{
    index: number;
    delta?: {
      content?: string;
      refusal?: string;
      function_call?: { name?: string; arguments?: string };
      tool_calls?: Array<{
        id?: string;
        function?: { name?: string; arguments?: string };
        custom?: { name?: string; input?: string };
      }>;
    };
    finish_reason?: string | null;
  }>;
  [key: string]: unknown;
}

export interface StreamingChatCompletionState {
  processedCountByIndex: Record<string, number>;
  previousResult?: (AiChatMessage | undefined)[];
}

function groupByChoiceIndex(chunks: ChatCompletionStreamChunk[]): ChatCompletionStreamChunk[][] {
  const grouped: ChatCompletionStreamChunk[][] = [];
  for (const chunk of chunks) {
    for (const choice of chunk.choices) {
      const idx = choice.index;
      if (!grouped[idx]) grouped[idx] = [];
      grouped[idx].push({ ...chunk, choices: [choice] });
    }
  }
  return grouped;
}

function chatCompletionStatus(chunks: ChatCompletionStreamChunk[]): string {
  const last = chunks[chunks.length - 1];
  return last?.choices?.[0]?.finish_reason != null ? 'completed' : 'in_progress';
}

/**
 * 流式 ChatCompletion 块的增量归约器：按 choice.index 分组、基于
 * state.processedCountByIndex 增量处理新到达片段，累积 content/refusal/
 * function_call/tool_calls（function/custom），产出每 index 一条消息。
 */
export function streamingChatCompletionToMessage(
  chunks: ChatCompletionStreamChunk[],
  prevState?: StreamingChatCompletionState,
): { messages: AiChatMessage[]; state: StreamingChatCompletionState } {
  const grouped = groupByChoiceIndex(chunks);
  let state = prevState;

  const results = grouped
    .map((groupChunks, groupIndex) => {
      const id = groupChunks[0]?.id ?? '';
      const status = chatCompletionStatus(groupChunks);
      const stateKey = `${id}:${groupChunks[0]?.choices?.[0]?.index ?? groupIndex}`;
      const processedCount = state?.processedCountByIndex?.[stateKey] ?? 0;
      const start = processedCount > 0 ? Math.min(processedCount, groupChunks.length) : 0;
      const chunksToProcess = state ? groupChunks.slice(start) : groupChunks;

      if (state && chunksToProcess.length === 0) return state.previousResult?.[groupIndex];

      const previousResult = state?.previousResult?.[groupIndex];
      let textContent = '';
      let refusal = '';
      const functionCall = { name: '', arguments: '' };
      const toolCalls: any[] = [];

      const prevContent = Array.isArray(previousResult?.content) ? previousResult.content : [];
      prevContent.forEach((item: any) => {
        item.content?.forEach?.((content: any) => {
          if (content.type === 'output_text') textContent += content.text;
          if (content.type === 'refusal') refusal += content.refusal;
        });
        if (item.type === 'function_call' && !item.id) {
          functionCall.name = item.name;
          functionCall.arguments = item.arguments;
        }
        if (item.type === 'tool_call' || (item.type === 'function_call' && item.id)) {
          toolCalls.push(item);
        }
      });

      for (const chunk of chunksToProcess) {
        const delta = chunk.choices[0]?.delta;
        if (delta?.content) textContent += delta.content;
        if (delta?.refusal) refusal += delta.refusal;
        if (delta?.function_call) {
          if (delta.function_call.name) functionCall.name += delta.function_call.name;
          functionCall.arguments += delta.function_call.arguments ?? '';
        }
        if (delta?.tool_calls) {
          for (const toolCall of delta.tool_calls) {
            const cur = toolCalls.find((t) => t.id === toolCall.id);
            if (cur) {
              if (toolCall?.function?.name) {
                cur.name += toolCall.function.name;
                cur.arguments += toolCall.function.arguments ?? '';
              } else if (toolCall?.custom?.name) {
                cur.name += toolCall.custom.name;
                cur.input = (cur.input ?? '') + (toolCall.custom.input ?? '');
              }
              cur.status = status;
            } else {
              toolCalls.push({
                ...toolCall?.function,
                ...toolCall?.custom,
                type: toolCall?.function ? 'function_call' : 'custom_call',
                id: toolCall.id,
              });
            }
          }
        }
      }

      const outputMessage = [
        textContent !== '' && { type: 'output_text', text: textContent },
        refusal !== '' && { type: 'refusal', refusal },
      ].filter(Boolean) as any[];
      const outputResult = [
        outputMessage.length > 0 && { type: 'message', id, role: 'assistant', status, content: outputMessage },
        functionCall.name !== '' && { type: 'function_call', ...functionCall },
        ...toolCalls,
      ].filter(Boolean) as any[];

      if (state && state.processedCountByIndex) {
        state.processedCountByIndex[stateKey] = groupChunks.length;
      } else {
        state = { processedCountByIndex: { [stateKey]: groupChunks.length } };
      }

      return { id, role: 'assistant', content: outputResult, status } as AiChatMessage;
    })
    .filter(Boolean) as AiChatMessage[];

  if (!state) state = { processedCountByIndex: {} };
  state.previousResult = results.map((r) => deepCloneChunk(r));
  return { messages: results, state };
}
