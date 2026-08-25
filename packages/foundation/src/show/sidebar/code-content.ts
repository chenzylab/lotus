export interface CodeItem {
  name?: string;
  key: string;
  isJson?: boolean;
  language?: string;
  content?: string;
  jsonViewerProps?: Record<string, any>;
  codeHighlightProps?: Record<string, any>;
}

/** 按 isJson 分流：true 走 JsonViewer 展示，否则走 CodeHighlight 高亮展示。 */
export function resolveCodeItemViewer(item: CodeItem): 'json' | 'code' {
  return item.isJson ? 'json' : 'code';
}
