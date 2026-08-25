import { describe, it, expect } from 'vitest';
import { responseToMessage, chatCompletionToMessage } from './adapter-response.js';

describe('responseToMessage', () => {
  it('提取 message 类型 output 的文本内容', () => {
    const message = responseToMessage({
      id: 'r1',
      model: 'gpt-5',
      status: 'completed',
      created_at: 100,
      output: [{ type: 'message', content: [{ type: 'output_text', text: 'hello' }] }],
      output_text: 'hello',
    });
    expect(message.role).toBe('assistant');
    expect(message.status).toBe('completed');
    expect(message.model).toBe('gpt-5');
    expect((message.content as any[])[0]).toEqual({ type: 'output_text', text: 'hello' });
  });

  it('reasoning output 转换成 reasoning ContentItem', () => {
    const message = responseToMessage({ output: [{ type: 'reasoning', summary: [{ type: 'summary_text', text: '思考中' }] }] });
    expect((message.content as any[])[0]).toEqual({ type: 'reasoning', summary: ['思考中'] });
  });

  it('function_call output 转换成 tool_call ContentItem', () => {
    const message = responseToMessage({
      output: [{ type: 'function_call', call_id: 'c1', name: 'search', arguments: '{}', status: 'completed' }],
    });
    expect((message.content as any[])[0]).toEqual({ type: 'tool_call', call_id: 'c1', name: 'search', arguments: '{}', status: 'completed' });
  });

  it('mcp_call output 转换成 mcp_call ContentItem', () => {
    const message = responseToMessage({
      output: [{ type: 'mcp_call', call_id: 'c1', server_label: 'srv', name: 'tool', status: 'in_progress' }],
    });
    expect((message.content as any[])[0]).toMatchObject({ type: 'mcp_call', server_label: 'srv', status: 'in_progress' });
  });

  it('无 output 时回退到 output_text', () => {
    const message = responseToMessage({ output_text: 'plain text' });
    expect(message.content).toBe('plain text');
  });

  it('未知 status 归一化为 completed', () => {
    const message = responseToMessage({ status: 'weird-status' as any });
    expect(message.status).toBe('completed');
  });
});

describe('chatCompletionToMessage', () => {
  it('提取 choice 内容和 finish_reason', () => {
    const message = chatCompletionToMessage({
      model: 'gpt-4',
      created: 100,
      choices: [{ message: { role: 'assistant', content: 'hi there' }, finish_reason: 'stop' }],
    });
    expect(message.status).toBe('completed');
    expect((message.content as any[])[0]).toEqual({ type: 'output_text', text: 'hi there' });
  });

  it('tool_calls 转换成 tool_call ContentItem 数组', () => {
    const message = chatCompletionToMessage({
      choices: [{ message: { tool_calls: [{ id: 't1', function: { name: 'fn', arguments: '{}' } }] }, finish_reason: 'tool_calls' }],
    });
    const toolCall = (message.content as any[]).find((c) => c.type === 'tool_call');
    expect(toolCall).toMatchObject({ call_id: 't1', name: 'fn', status: 'completed' });
  });

  it('finish_reason=length 映射为 incomplete', () => {
    const message = chatCompletionToMessage({ choices: [{ message: { content: 'x' }, finish_reason: 'length' }] });
    expect(message.status).toBe('incomplete');
  });

  it('finish_reason=content_filter 映射为 failed', () => {
    const message = chatCompletionToMessage({ choices: [{ message: { content: 'x' }, finish_reason: 'content_filter' }] });
    expect(message.status).toBe('failed');
  });
});
