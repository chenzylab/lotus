import { describe, it, expect } from 'vitest';
import { inputToMessage, inputToChatCompletion } from './bridge.js';

describe('inputToMessage', () => {
  it('提取文本内容为 input_text', () => {
    const msg = inputToMessage({ inputContents: [{ type: 'text', text: 'hello' }] }, { id: 'm1' });
    expect(msg.id).toBe('m1');
    expect(msg.role).toBe('user');
    expect(msg.content).toEqual([{ type: 'input_text', text: 'hello' }]);
  });

  it('图片附件转换成 input_image', () => {
    const msg = inputToMessage({ attachments: [{ uid: 'a1', name: 'photo.png', url: 'http://x/photo.png' }] });
    expect(msg.content).toEqual([{ type: 'input_image', image_url: 'http://x/photo.png' }]);
  });

  it('非图片附件转换成 input_file', () => {
    const msg = inputToMessage({ attachments: [{ uid: 'a2', name: 'doc.pdf', url: 'http://x/doc.pdf' }] });
    expect(msg.content).toEqual([{ type: 'input_file', file_name: 'doc.pdf', file_url: 'http://x/doc.pdf' }]);
  });

  it('缺省 id 回退空字符串', () => {
    expect(inputToMessage({}).id).toBe('');
  });

  it('传入 model 时写入消息', () => {
    expect(inputToMessage({}, { model: 'gpt-5' }).model).toBe('gpt-5');
  });
});

describe('inputToChatCompletion', () => {
  it('文本内容转换成 text part', () => {
    const result = inputToChatCompletion({ inputContents: [{ type: 'text', text: 'hi' }] });
    expect(result).toEqual({ role: 'user', content: [{ type: 'text', text: 'hi' }] });
  });

  it('图片附件转换成 image_url part', () => {
    const result = inputToChatCompletion({ attachments: [{ uid: 'a1', name: 'a.png', url: 'http://x/a.png' }] });
    expect(result.content).toEqual([{ type: 'image_url', image_url: { url: 'http://x/a.png' } }]);
  });

  it('非图片附件转换成 file part', () => {
    const result = inputToChatCompletion({ attachments: [{ uid: 'a2', name: 'a.pdf', url: 'http://x/a.pdf' }] });
    expect(result.content).toEqual([{ type: 'file', file: { filename: 'a.pdf', file_data: 'http://x/a.pdf' } }]);
  });
});
