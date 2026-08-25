export interface FileItemProps {
  name?: string;
  key: string;
  content?: string;
  editable?: boolean;
}

export interface ImageUploadNodeOptions {
  accept?: string;
  maxSize?: number;
  onChange?: (file: File) => void;
  onSuccess?: (src: string, file: File) => void;
  onError?: (error: unknown, file: File) => void;
}

/**
 * MenuBar 工具按钮的激活态判定（对齐 tiptap `editor.isActive` 语义），纯函数
 * 抽出方便单测：不需要真实 Editor 实例，只需要一个返回激活态的探测函数集合。
 */
export interface MenuBarActiveState {
  bold: boolean;
  italic: boolean;
  strike: boolean;
  code: boolean;
  heading1: boolean;
  heading2: boolean;
  heading3: boolean;
  bulletList: boolean;
  orderedList: boolean;
  blockquote: boolean;
  codeBlock: boolean;
  alignLeft: boolean;
  alignCenter: boolean;
  alignRight: boolean;
}

export function defaultMenuBarActiveState(): MenuBarActiveState {
  return {
    bold: false,
    italic: false,
    strike: false,
    code: false,
    heading1: false,
    heading2: false,
    heading3: false,
    bulletList: false,
    orderedList: false,
    blockquote: false,
    codeBlock: false,
    alignLeft: false,
    alignCenter: false,
    alignRight: false,
  };
}
