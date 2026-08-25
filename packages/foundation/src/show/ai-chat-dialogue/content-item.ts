/** 文件大小人类可读格式化（B/KB/MB/GB，保留 1 位小数，字节数精确到整数不加小数）。 */
export function formatFileSize(bytes: number | undefined): string {
  if (bytes === undefined || Number.isNaN(bytes)) return '';
  if (bytes < 1024) return `${bytes} B`;
  const units = ['KB', 'MB', 'GB', 'TB'];
  let value = bytes / 1024;
  let unitIndex = 0;
  while (value >= 1024 && unitIndex < units.length - 1) {
    value /= 1024;
    unitIndex += 1;
  }
  return `${value.toFixed(1)} ${units[unitIndex]}`;
}

/** 尝试把工具调用/MCP 调用的 arguments/output 字符串格式化成缩进 JSON；解析失败原样返回。 */
export function formatToolArguments(raw: string | undefined): string {
  if (!raw) return '';
  try {
    return JSON.stringify(JSON.parse(raw), null, 2);
  } catch {
    return raw;
  }
}

export type ToolCallStatus = 'in_progress' | 'completed' | 'failed';

/** 工具调用状态归一化：未知/缺省值一律视为 in_progress（对齐"未标记完成即认为仍在进行"的保守语义）。 */
export function normalizeToolCallStatus(status: string | undefined): ToolCallStatus {
  if (status === 'completed' || status === 'failed') return status;
  return 'in_progress';
}
