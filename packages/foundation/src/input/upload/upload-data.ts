/**
 * Upload 核心数据结构与文件状态机纯函数，移植自 Semi
 * semi-foundation/upload/foundation.ts 的算法思路（对齐参考实现
 * chenzy.design 已验证的设计）。
 *
 * 只实现三档 listType（'list'/'picture'/'none'）——不做 Semi 不存在的
 * 'picture-list'。不实现并发队列/pause/abort——Semi 没有，chenzy.design
 * spec 文档声称有但实际代码未落地，是文档超前于代码的陷阱，视为未验证。
 * 不预先实现 'validating'/'illegal' 这两个 Semi 声明但从未真正触发的
 * 死状态，除非后续需要才补上触发时机。
 */

export type FileStatus = 'wait' | 'uploading' | 'success' | 'uploadFail' | 'validateFail';
export type ListType = 'list' | 'picture' | 'none';
export type UploadTrigger = 'auto' | 'custom';
export type DragAreaStatus = 'default' | 'legal';

export interface FileItem {
  uid: string;
  name: string;
  size: number;
  status: FileStatus;
  percent: number;
  url?: string;
  fileInstance?: File;
  validateMessage?: string;
  response?: unknown;
}

export interface BeforeUploadResult {
  shouldUpload?: boolean;
  status?: FileStatus;
  autoRemove?: boolean;
  validateMessage?: string;
  fileInstance?: File;
}

function generateUid(): string {
  return `upload-${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;
}

/** accept 匹配：扩展名（.png）、MIME 类型（image/png）、通配（image/*）三种写法。 */
export function matchAccept(file: File, accept: string | undefined): boolean {
  if (!accept) return true;
  const patterns = accept.split(',').map((p) => p.trim()).filter(Boolean);
  if (patterns.length === 0) return true;
  const fileName = file.name.toLowerCase();
  const fileType = (file.type || '').toLowerCase();
  return patterns.some((pattern) => {
    const p = pattern.toLowerCase();
    if (p.startsWith('.')) return fileName.endsWith(p);
    if (p.endsWith('/*')) return fileType.startsWith(p.slice(0, -1));
    return fileType === p;
  });
}

/**
 * 文件大小校验，单位 KB。对齐 chenzy.design 的显式 undefined 守卫写法（不是
 * Semi 那种依赖 `undefined * 1024 = NaN` 的隐式正确性——同样能跑对，但下一次
 * 有人重构成别的比较写法就会真的出 bug，这里直接写清楚更安全）。
 */
export function checkFileSize(
  sizeBytes: number,
  maxSize: number | undefined,
  minSize: number | undefined,
): boolean {
  const sizeKB = sizeBytes / 1024;
  if (maxSize !== undefined && sizeKB > maxSize) return false;
  if (minSize !== undefined && sizeKB < minSize) return false;
  return true;
}

export interface BuildFileItemOptions {
  maxSize?: number;
  minSize?: number;
  uploadTrigger: UploadTrigger;
}

/** File → FileItem，含大小校验（越界直接标 validateFail，对齐 Semi 顺序：校验早于状态默认赋值）。 */
export function buildFileItem(file: File, options: BuildFileItemOptions): FileItem {
  const sizeOk = checkFileSize(file.size, options.maxSize, options.minSize);
  return {
    uid: generateUid(),
    name: file.name,
    size: file.size,
    status: sizeOk ? (options.uploadTrigger === 'auto' ? 'uploading' : 'wait') : 'validateFail',
    percent: 0,
    fileInstance: file,
    validateMessage: sizeOk ? undefined : '文件大小超出限制',
  };
}

/** limit 裁剪：limit===1 时是替换语义（保留新选中的最后一个），否则保留能放下的前 N 个。 */
export function applyLimit(
  existing: FileItem[],
  incoming: FileItem[],
  limit: number | undefined,
): { fileList: FileItem[]; exceeded: FileItem[] } {
  if (limit === undefined) return { fileList: [...existing, ...incoming], exceeded: [] };
  if (limit === 1) {
    const kept = incoming.slice(-1);
    return { fileList: kept, exceeded: [...existing, ...incoming.slice(0, -1)] };
  }
  const room = Math.max(0, limit - existing.length);
  return { fileList: [...existing, ...incoming.slice(0, room)], exceeded: incoming.slice(room) };
}

export function isImageFile(item: FileItem): boolean {
  const type = item.fileInstance?.type ?? '';
  return /^image\//.test(type) || /\.(png|jpe?g|gif|webp|bmp|svg)$/i.test(item.name);
}
