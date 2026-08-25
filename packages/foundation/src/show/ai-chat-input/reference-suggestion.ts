import type { AiInputAttachment, AiInputReference } from './content.js';

/** 建议项（对齐 Semi Suggestion）：纯字符串或含 content 字段的对象。 */
export type AiInputSuggestion = string | { content: string; [key: string]: unknown };

/** 取建议项的显示文本（string 直接返回，对象取 content）。 */
export function suggestionContent(suggestion: AiInputSuggestion): string {
  return typeof suggestion === 'string' ? suggestion : (suggestion?.content ?? '');
}

/**
 * 建议面板键盘导航：从 current 沿 dir（-1=上/+1=下）环绕移动，返回新 activeIndex。
 * len<=0 返回 -1（无项）；current<0（未选中）时：向下从 0 开始、向上从末项开始。
 */
export function nextSuggestionIndex(current: number, len: number, dir: -1 | 1): number {
  if (len <= 0) return -1;
  if (current < 0) return dir === 1 ? 0 : len - 1;
  return (current + dir + len) % len;
}

/** 取引用项的显示文本：type='text' 用 content，否则用 name（缺省回退到 id）。 */
export function referenceLabel(ref: AiInputReference): string {
  if (ref.type === 'text') return ref.content ?? '';
  return ref.name ?? ref.id;
}

/** 图片 mime 前缀（对齐 Semi strings.PIC_PREFIX）。 */
export const AI_INPUT_PIC_PREFIX = 'image/';

/** 按图片处理的后缀白名单（对齐 Semi strings.PIC_SUFFIX_ARRAY，逐条一致，不含 svg）。 */
export const AI_INPUT_PIC_SUFFIX = ['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp'];

/**
 * 取附件/引用的类型标记（对齐 Semi getAttachmentType）：显式 type 优先，
 * 其次取 name 的后缀，再退到 fileInstance.type 的尾段，最后 'UNKNOWN'。
 */
export function getAttachmentType(item: AiInputAttachment | AiInputReference): string {
  const { type, name, fileInstance } = item;
  if (type) return type;
  const suffix = name?.split('.').pop();
  return suffix ?? fileInstance?.type?.split('/').pop() ?? 'UNKNOWN';
}

/**
 * 是否按图片渲染（对齐 Semi isImageType）：fileInstance.type 以 image/ 开头，
 * 或 name 的后缀命中图片白名单。与 Semi 一致地只看 name 不看 url，且白名单不含 svg。
 */
export function isImageType(item: AiInputAttachment | AiInputReference): boolean {
  const { name, fileInstance } = item;
  const suffix = name?.split('.').pop();
  return Boolean(fileInstance?.type?.startsWith(AI_INPUT_PIC_PREFIX)) || (suffix !== undefined && AI_INPUT_PIC_SUFFIX.includes(suffix));
}

/**
 * 后缀 → 图标分类（对齐 Semi getContentType，逐条照搬）。`ts` 在 Semi 的 Map 里
 * 出现两次（code 与 video），Map 后写覆盖前写故实际取 'video'——这是 Semi 的
 * 既定行为，作为契约照搬，不"修正"。
 */
export function getContentType(type: string): string {
  return AI_INPUT_CONTENT_TYPE_MAP.get(type) ?? 'unknown';
}

const AI_INPUT_CONTENT_TYPE_MAP = new Map<string, string>([
  ['docx', 'word'], ['doc', 'word'], ['txt', 'word'], ['epub', 'word'], ['mobi', 'word'],
  ['js', 'code'], ['ts', 'code'], ['jsx', 'code'], ['tsx', 'code'], ['java', 'code'],
  ['py', 'code'], ['c', 'code'], ['cpp', 'code'], ['go', 'code'], ['rust', 'code'],
  ['php', 'code'], ['sql', 'code'], ['html', 'code'], ['css', 'code'], ['scss', 'code'],
  ['less', 'code'], ['md', 'code'], ['json', 'code'],
  ['xlsx', 'excel'], ['xls', 'excel'], ['pptx', 'ppt'], ['ppt', 'ppt'],
  ['mp4', 'video'], ['mkv', 'video'], ['avi', 'video'], ['mov', 'video'], ['wmv', 'video'],
  ['prores', 'video'], ['flv', 'video'], ['ts', 'video'], ['webm', 'video'], ['3gp', 'video'],
  ['flac', 'audio'], ['wav', 'audio'], ['alac', 'audio'], ['ape', 'audio'], ['mp3', 'audio'],
  ['aac', 'audio'], ['ogg', 'audio'], ['wma', 'audio'], ['m4a', 'audio'], ['amr', 'audio'],
  ['midi', 'audio'],
  ['png', 'image'], ['jpg', 'image'], ['jpeg', 'image'], ['gif', 'image'], ['bmp', 'image'],
  ['webp', 'image'],
  ['pdf', 'pdf'],
]);

/** 该引用是否应按图片渲染。与附件共用 isImageType。 */
export function isImageReference(ref: AiInputReference): boolean {
  return isImageType(ref);
}
