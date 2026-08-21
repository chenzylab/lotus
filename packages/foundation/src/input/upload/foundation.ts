import { Foundation, type Adapter } from '../../base/adapter.js';
import {
  buildFileItem,
  applyLimit,
  matchAccept,
  type FileItem,
  type BeforeUploadResult,
  type DragAreaStatus,
  type UploadTrigger,
} from './upload-data.js';

export * from './upload-data.js';

export interface UploadState {
  fileList: FileItem[];
  dragAreaStatus: DragAreaStatus;
}

export interface UploadFoundationOptions {
  accept?: string;
  maxSize?: number;
  minSize?: number;
  limit?: number;
  uploadTrigger: UploadTrigger;
}

/**
 * Upload 状态机：文件选择/校验/limit裁剪/状态流转（wait→uploading→success|
 * uploadFail|validateFail）+ 拖拽悬停态。移植自 Semi
 * semi-foundation/upload/foundation.ts 的算法思路（对齐参考实现
 * chenzy.design 已验证的设计）。
 *
 * 真正的网络 IO（XMLHttpRequest 构造、FormData 拼装、headers 设置、
 * onprogress/onload/onerror 监听）完全下沉到 `.tsrx` 组件层，不放进
 * Foundation——这是 lotus 既有惯例（对齐 TreeSelect 的 loadData 异步懒加载
 * 同样在 `.tsrx` 层发起），也是本次调研确认 chenzy.design 采用的更优模式
 * （优于 Semi 直接把 `new XMLHttpRequest()` 塞进 Foundation 类方法）。
 * Foundation 只提供"收到上传进度/成功/失败回调后如何迁移某个文件项状态"
 * 这类纯状态转换方法，不持有任何 XHR 引用。
 *
 * 对 Semi 源码的主动修正：
 * 1. checkFileSize 用显式 `!== undefined` 守卫（upload-data.ts），不依赖
 *    `undefined * 1024 = NaN` 的隐式正确性；
 * 2. timeout 若支持，交由 .tsrx 层真正接到 xhr.timeout（Semi 这里是 dead
 *    prop，声明了但从未使用）；
 * 3. 不实现 Semi 声明但从未真正触发的 'validating'/拖拽 'illegal' 死状态。
 */
export class UploadFoundation extends Foundation<UploadState> {
  private opts: UploadFoundationOptions;

  constructor(adapter: Adapter<UploadState>, opts: UploadFoundationOptions) {
    super(adapter);
    this.opts = opts;
  }

  // ===================== 文件选择与校验 =====================

  /** 按 accept 过滤，返回匹配/不匹配两个分组，供 .tsrx 层决定不匹配的如何提示（onAcceptInvalid）。 */
  filterByAccept(files: File[]): { matched: File[]; rejected: File[] } {
    const matched: File[] = [];
    const rejected: File[] = [];
    for (const file of files) {
      (matchAccept(file, this.opts.accept) ? matched : rejected).push(file);
    }
    return { matched, rejected };
  }

  /**
   * File[] → FileItem[]，含大小校验 + limit 裁剪。返回新增的 fileList
   * （已按 limit 追加到现有列表）和被 limit 拒绝的项，供 .tsrx 层决定要不要
   * 调 onExceed。不在这里发起上传——是否自动上传由 .tsrx 层读 uploadTrigger
   * 和返回的 fileList 里 status==='uploading' 的项自行发起。
   */
  addFiles(files: File[]): { fileList: FileItem[]; added: FileItem[]; exceeded: FileItem[] } {
    const { fileList } = this.getState();
    const built = files.map((file) =>
      buildFileItem(file, { maxSize: this.opts.maxSize, minSize: this.opts.minSize, uploadTrigger: this.opts.uploadTrigger }),
    );
    const { fileList: nextList, exceeded } = applyLimit(fileList, built, this.opts.limit);
    this.setState({ fileList: nextList });
    const added = nextList.filter((item) => built.some((b) => b.uid === item.uid));
    return { fileList: nextList, added, exceeded };
  }

  // ===================== beforeUpload 决议 =====================

  /** 把 beforeUpload 的三态返回值（boolean/object/Promise 已由调用方 await 完）归一化为决议结果。 */
  resolveBeforeUploadResult(raw: boolean | BeforeUploadResult | undefined): BeforeUploadResult {
    if (raw === undefined || raw === true) return { shouldUpload: true };
    if (raw === false) return { shouldUpload: false, status: 'validateFail' };
    return { shouldUpload: raw.shouldUpload !== false, ...raw };
  }

  /** 应用 beforeUpload 决议结果到某个文件项：shouldUpload=false 时标记状态，fileInstance 替换时同步 size/name。 */
  applyBeforeUploadResult(uid: string, result: BeforeUploadResult): FileItem | null {
    const { fileList } = this.getState();
    const idx = fileList.findIndex((item) => item.uid === uid);
    if (idx === -1) return null;
    const current = fileList[idx]!;
    const next: FileItem = {
      ...current,
      status: result.shouldUpload === false ? (result.status ?? 'validateFail') : 'uploading',
      validateMessage: result.validateMessage ?? current.validateMessage,
    };
    if (result.fileInstance) {
      next.fileInstance = result.fileInstance;
      next.name = result.fileInstance.name;
      next.size = result.fileInstance.size;
    }
    const nextList = [...fileList];
    nextList[idx] = next;
    this.setState({ fileList: nextList });
    return next;
  }

  // ===================== 上传生命周期状态迁移 =====================

  /** post() 触发前把文件项状态置为 uploading（custom uploadTrigger 场景下用户手动触发上传时调用）。 */
  markUploading(uid: string): FileItem | null {
    return this.patchFile(uid, { status: 'uploading', percent: 0 });
  }

  handleProgress(uid: string, percent: number): FileItem | null {
    return this.patchFile(uid, { status: 'uploading', percent: Math.min(100, Math.max(0, percent)) });
  }

  handleSuccess(uid: string, response: unknown): FileItem | null {
    return this.patchFile(uid, { status: 'success', percent: 100, response });
  }

  handleError(uid: string, message?: string): FileItem | null {
    return this.patchFile(uid, { status: 'uploadFail', validateMessage: message });
  }

  /** retry 不检查当前 status（对齐 Semi：约束交给 .tsrx 层按 showRetry && status==='uploadFail' 判断是否展示按钮）。 */
  retry(uid: string): FileItem | null {
    return this.patchFile(uid, { status: 'uploading', percent: 0, validateMessage: undefined });
  }

  private patchFile(uid: string, patch: Partial<FileItem>): FileItem | null {
    const { fileList } = this.getState();
    const idx = fileList.findIndex((item) => item.uid === uid);
    if (idx === -1) return null;
    const next = { ...fileList[idx]!, ...patch };
    const nextList = [...fileList];
    nextList[idx] = next;
    this.setState({ fileList: nextList });
    return next;
  }

  // ===================== 移除 / 替换 =====================

  remove(uid: string): FileItem[] {
    const { fileList } = this.getState();
    const next = fileList.filter((item) => item.uid !== uid);
    this.setState({ fileList: next });
    return next;
  }

  /** replace：用新 FileItem 整体替换某个 uid 对应的旧项，位置保持不变。 */
  replace(uid: string, file: File): { fileList: FileItem[]; replaced: FileItem } | null {
    const { fileList } = this.getState();
    const idx = fileList.findIndex((item) => item.uid === uid);
    if (idx === -1) return null;
    const replaced = buildFileItem(file, {
      maxSize: this.opts.maxSize,
      minSize: this.opts.minSize,
      uploadTrigger: this.opts.uploadTrigger,
    });
    const nextList = [...fileList];
    nextList[idx] = replaced;
    this.setState({ fileList: nextList });
    return { fileList: nextList, replaced };
  }

  clear(): void {
    this.setState({ fileList: [] });
  }

  // ===================== 拖拽悬停态 =====================

  setDragAreaStatus(status: DragAreaStatus): void {
    this.setState({ dragAreaStatus: status });
  }

  // ===================== 受控同步 =====================

  syncFileList(fileList: FileItem[]): void {
    this.setState({ fileList });
  }
}
