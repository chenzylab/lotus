/**
 * AiChatInput 的核心数据结构与阶段 1 纯函数：发送态判定、快捷键判定、
 * MessageContent 组装、tiptap 文档 JSON → Content[] 归一。全部框架无关，
 * tiptap Editor 实例/DOM 归渲染层，全功能移植自 chenzy.design 已验证实现
 * （对齐 Semi AIChatInput 语义，但 messageToChatInput/chatInputToChatCompletion
 * 桥接函数是 chenzy.design/lotus 自建，Semi 官方并不提供）。
 */

/** 富文本输出块（tiptap JSON 经 transformer 归一后的一段内容）。 */
export interface AiInputContent {
  type: string;
  [key: string]: unknown;
}

/** 上传附件（对齐 Semi Attachment）。 */
export interface AiInputAttachment {
  uid?: string;
  name?: string;
  status?: string;
  size?: string | number;
  url?: string;
  /** 类型标记：不是枚举，是"后缀或 mime 尾段"——getAttachmentType 优先取本字段，缺省时才从 name 后缀/fileInstance.type 推导。 */
  type?: string;
  /** 原始 File（Upload 透传），用于按 mime 判定图片与推导类型。 */
  fileInstance?: { type?: string };
  /** 上传进度百分比（配合 status='uploading' 显示环形进度）。 */
  percent?: number;
  [key: string]: unknown;
}

/**
 * 引用块（渲染于编辑区上方 top area）。对齐 Semi Reference：type='text' 时显示
 * content，其它类型显示 name；图片按 isImageType 判定后显示缩略图。
 */
export interface AiInputReference {
  /**
   * 类型标记。**可选**：缺省时由 getAttachmentType 从 name 后缀推导。
   * Semi 的 TS 声明把它写成必填，但官方 demo 的引用项大多不带 type、纯靠后缀
   * 推导（demo 是无类型 JSX，编译期查不出来）。按实际契约声明为可选。
   */
  type?: string;
  id: string;
  /** type='text' 时的文本内容。 */
  content?: string;
  /** 非文本类型的显示名。 */
  name?: string;
  /** 图片/文件的 URL（图片类型用作缩略图 src）。 */
  url?: string;
  fileInstance?: { type?: string };
  [key: string]: unknown;
}

/** onMessageSend 载荷，对齐 Semi MessageContent。 */
export interface AiInputMessageContent {
  references?: AiInputReference[];
  attachments?: AiInputAttachment[];
  inputContents?: AiInputContent[];
  setup?: Record<string, unknown>;
}

/** 发送快捷键：enter = Enter 发送/Shift+Enter 换行；shift+enter 则相反。 */
export type AiInputSendHotKey = 'enter' | 'shift+enter';

/** onContentChange 载荷。 */
export interface AiInputChangePayload {
  text: string;
  html: string;
  json: unknown;
}

/**
 * 判定一次 Enter 键是否应触发发送（而非换行）。
 * IME 组字中（composing）永不发送，交由渲染层前置拦截。
 */
export function isSendHotKey(key: string, shiftKey: boolean, sendHotKey: AiInputSendHotKey): boolean {
  if (key !== 'Enter') return false;
  return sendHotKey === 'enter' ? !shiftKey : shiftKey;
}

/**
 * 解析当前是否可发送：显式传入 canSend（受控）时直接返回它；
 * 否则富文本非空或有附件即可发送。
 */
export function resolveCanSend(params: {
  canSend?: boolean | undefined;
  isEmpty: boolean;
  attachments?: AiInputAttachment[] | undefined;
}): boolean {
  const { canSend, isEmpty, attachments } = params;
  if (canSend !== undefined) return canSend;
  const validRichText = !isEmpty;
  const validAttachment = Array.isArray(attachments) && attachments.length > 0;
  return validRichText || validAttachment;
}

/** 组装 onMessageSend 载荷。空字段省略，保持载荷精简。 */
export function buildMessageContent(params: {
  inputContents?: AiInputContent[] | undefined;
  attachments?: AiInputAttachment[] | undefined;
  references?: AiInputReference[] | undefined;
  setup?: Record<string, unknown> | undefined;
}): AiInputMessageContent {
  const { inputContents, attachments, references, setup } = params;
  const msg: AiInputMessageContent = {};
  if (inputContents && inputContents.length > 0) msg.inputContents = inputContents;
  if (attachments && attachments.length > 0) msg.attachments = attachments;
  if (references && references.length > 0) msg.references = references;
  if (setup && Object.keys(setup).length > 0) msg.setup = setup;
  return msg;
}

/** 零宽字符（对齐 Semi ZERO_WIDTH_CHAR）：inputSlot 空态占位锚点，归一时剔除。 */
export const AI_INPUT_ZERO_WIDTH = '﻿';

interface DocNode {
  type?: string;
  text?: string;
  content?: DocNode[];
  attrs?: Record<string, unknown>;
}

/**
 * 单节点 → AiInputContent（对齐 Semi transformText/transformSelectSlot/
 * transformSkillSlot/transformInputSlot/transformHardBreak）。只有 skillSlot
 * 保留为结构化对象（type/value/label/hasTemplate），其余（text/selectSlot/
 * inputSlot/hardBreak）一律转成 `{type:'text', text}`，供 traverse 与相邻文本块合并。
 */
function transformNode(node: DocNode): AiInputContent | undefined {
  switch (node.type) {
    case 'text': {
      const t = node.text ?? '';
      return { type: 'text', text: t === AI_INPUT_ZERO_WIDTH ? '' : t };
    }
    case 'hardBreak':
      return { type: 'text', text: '\n' };
    case 'selectSlot': {
      const v = node.attrs?.value;
      return { type: 'text', text: typeof v === 'string' ? v : '' };
    }
    case 'skillSlot': {
      const { value, label, hasTemplate } = node.attrs ?? {};
      const out: AiInputContent = { type: 'skillSlot' };
      if (value !== undefined) out.value = value;
      if (label !== undefined) out.label = label;
      if (hasTemplate !== undefined) out.hasTemplate = hasTemplate;
      return out;
    }
    case 'inputSlot': {
      const first = node.content?.[0];
      const text = first?.text ?? '';
      const usePlaceholder = text === AI_INPUT_ZERO_WIDTH || text.length === 0;
      return { type: 'text', text: usePlaceholder ? ((node.attrs?.placeholder as string) ?? '') : text };
    }
    default:
      return undefined;
  }
}

/**
 * 把 tiptap 文档 JSON 归一为 AiInputContent[]。对齐 Semi transformJSONResult：
 * 递归遍历 doc→paragraph→叶子节点，paragraph 之间插入 `\n`（与前一个 text 块
 * 合并，无前项则单独追加），叶子节点转换结果为 text 时与末项 text 合并、为空
 * 丢弃；skillSlot 转换结果保留为独立结构化对象，不与相邻文本合并。transformer
 * （Map<nodeType, fn>）覆盖特定节点的转换，在内置转换之后兜底（内置类型优先）。
 */
export function transformDocToContents(json: unknown, transformer?: Map<string, (node: unknown) => AiInputContent>): AiInputContent[] {
  const doc = json as DocNode | undefined;
  if (!doc) return [];
  const output: AiInputContent[] = [];

  const push = (result: AiInputContent): void => {
    if (result.type === 'text') {
      const last = output[output.length - 1];
      if (last && last.type === 'text') {
        last.text = `${last.text as string}${result.text as string}`;
        return;
      }
      if (typeof result.text === 'string') {
        if (result.text.length > 0) output.push(result);
        return;
      }
      output.push(result);
      return;
    }
    output.push(result);
  };

  const traverse = (node: DocNode): void => {
    const content = node.content ?? [];
    if (node.type === 'doc') {
      content.forEach(traverse);
      return;
    }
    if (node.type === 'paragraph') {
      if (output.length > 0) {
        const last = output[output.length - 1];
        if (last && last.type === 'text') last.text = `${last.text as string}\n`;
        else output.push({ type: 'text', text: '\n' });
      }
      content.forEach(traverse);
      return;
    }
    const result = transformNode(node) ?? transformer?.get(node.type ?? '')?.(node);
    if (result) push(result);
  };

  traverse(doc);
  return output;
}
