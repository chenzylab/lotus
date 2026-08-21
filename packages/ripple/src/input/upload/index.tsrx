import { track, untrack, effect } from 'ripple';
import {
    UploadFoundation,
    isImageFile,
    type UploadState,
    type FileItem,
    type ListType,
    type UploadTrigger,
    type BeforeUploadResult,
} from '@lotus/foundation/input/upload';
import { Progress } from '../../feedback/progress/index.tsrx';
import { IconButton } from '../../basic/icon-button/index.tsrx';
import { IconUpload, IconUploadError, IconClose, IconFile, IconRefresh } from '@lotus/icons';

export type { ListType, UploadTrigger, FileItem };

export interface UploadHeaders {
    [key: string]: string;
}

export interface CustomRequestArgs {
    file: File;
    fileName: string;
    data?: Record<string, unknown>;
    headers?: UploadHeaders;
    action: string;
    withCredentials?: boolean;
    onProgress: (percent: number) => void;
    onSuccess: (response: unknown) => void;
    onError: (message?: string) => void;
}

export interface UploadProps {
    action: string;
    headers?: UploadHeaders | ((file: FileItem) => UploadHeaders);
    data?: Record<string, unknown> | ((file: FileItem) => Record<string, unknown>);
    name?: string;
    accept?: string;
    multiple?: boolean;
    limit?: number;
    maxSize?: number;
    minSize?: number;
    fileList?: FileItem[];
    defaultFileList?: FileItem[];
    disabled?: boolean;
    listType?: ListType;
    uploadTrigger?: UploadTrigger;
    draggable?: boolean;
    dragMainText?: string;
    dragSubText?: string;
    showRetry?: boolean;
    showReplace?: boolean;
    withCredentials?: boolean;
    beforeUpload?: (file: File, fileItem: FileItem) => boolean | BeforeUploadResult | Promise<boolean | BeforeUploadResult>;
    customRequest?: (args: CustomRequestArgs) => void;
    onChange?: (fileList: FileItem[]) => void;
    onSuccess?: (response: unknown, file: FileItem) => void;
    onError?: (error: unknown, file: FileItem) => void;
    onProgress?: (percent: number, file: FileItem) => void;
    onRemove?: (file: FileItem, fileList: FileItem[]) => void;
    onRetry?: (file: FileItem) => void;
    onExceed?: (files: File[]) => void;
    onAcceptInvalid?: (files: File[]) => void;
    'aria-label'?: string;
    style?: Record<string, any>;
    class?: string;
}

function formatFileSize(bytes: number): string {
    if (bytes < 1024) return `${bytes}B`;
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)}KB`;
    return `${(bytes / (1024 * 1024)).toFixed(1)}MB`;
}

function resolveHeaders(headers: UploadProps['headers'], item: FileItem): UploadHeaders | undefined {
    return typeof headers === 'function' ? headers(item) : headers;
}

function resolveData(data: UploadProps['data'], item: FileItem): Record<string, unknown> | undefined {
    return typeof data === 'function' ? data(item) : data;
}

/** 内置 XHR 上传：FormData 拼装 + headers 设置 + onprogress/onload/onerror 监听。 */
function xhrUpload(args: CustomRequestArgs) {
    const formData = new FormData();
    if (args.data) {
        for (const key of Object.keys(args.data)) {
            formData.append(key, String(args.data[key]));
        }
    }
    formData.append(args.fileName, args.file);

    const xhr = new XMLHttpRequest();
    xhr.open('POST', args.action, true);
    xhr.withCredentials = !!args.withCredentials;
    if (args.headers) {
        for (const key of Object.keys(args.headers)) {
            xhr.setRequestHeader(key, args.headers[key]!);
        }
    }
    xhr.upload.onprogress = (event) => {
        if (!event.lengthComputable) return;
        args.onProgress(Math.round((event.loaded / event.total) * 100));
    };
    xhr.onload = () => {
        if (xhr.status >= 200 && xhr.status < 300) {
            let response: unknown = xhr.responseText;
            try { response = JSON.parse(xhr.responseText); } catch { /* 非 JSON 响应，原样返回文本 */ }
            args.onSuccess(response);
        } else {
            args.onError(`上传失败：HTTP ${xhr.status}`);
        }
    };
    xhr.onerror = () => args.onError('网络错误');
    xhr.send(formData);
}

interface FileCardProps {
    item: FileItem;
    listType: ListType;
    showRetry: boolean;
    showReplace: boolean;
    disabled: boolean;
    onRemove: (item: FileItem) => void;
    onRetryClick: (item: FileItem) => void;
    onReplaceClick: (item: FileItem) => void;
}

function statusLabel(status: FileItem['status']): string {
    if (status === 'uploadFail') return '上传失败';
    if (status === 'validateFail') return '校验失败';
    if (status === 'success') return '上传成功';
    if (status === 'uploading') return '上传中';
    return '等待上传';
}

function FileCard(&{ item, listType, showRetry, showReplace, disabled, onRemove, onRetryClick, onReplaceClick }: FileCardProps) @{
    <>
    <div class={['lotus-upload-file-card', `lotus-upload-file-card-${listType}`, `lotus-upload-file-card-${item.status}`].join(' ')} role="listitem">
        <div class="lotus-upload-file-thumbnail">
            @if (isImageFile(item) && item.fileInstance) {
                <img
                    class="lotus-upload-file-thumbnail-img"
                    src={URL.createObjectURL(item.fileInstance)}
                    alt={item.name}
                    onError={(e: Event) => { (e.target as HTMLImageElement).style.display = 'none'; }}
                />
            } @else if (item.status === 'uploadFail' || item.status === 'validateFail') {
                <IconUploadError />
            } @else {
                <IconFile />
            }
        </div>
        <div class="lotus-upload-file-info">
            <div class="lotus-upload-file-name" title={item.name}>{item.name}</div>
            <div class="lotus-upload-file-meta">
                <span class="lotus-upload-file-size">{formatFileSize(item.size)}</span>
                @if (item.status === 'uploadFail' || item.status === 'validateFail') {
                    <span class="lotus-upload-file-error-msg">{item.validateMessage ?? statusLabel(item.status)}</span>
                }
            </div>
            @if (item.status === 'uploading') {
                <Progress
                    percent={item.percent}
                    type={listType === 'picture' ? 'circle' : 'line'}
                    size="small"
                    aria-label={`${item.name} 上传进度`}
                />
            }
        </div>
        <div class="lotus-upload-file-actions">
            @if (showRetry && item.status === 'uploadFail') {
                <IconButton
                    icon={<IconRefresh />}
                    theme="borderless"
                    type="tertiary"
                    size="small"
                    disabled={disabled}
                    aria-label={`重试 ${item.name}`}
                    onClick={() => onRetryClick(item)}
                />
            }
            @if (showReplace) {
                <IconButton
                    icon={<IconUpload />}
                    theme="borderless"
                    type="tertiary"
                    size="small"
                    disabled={disabled}
                    aria-label={`替换 ${item.name}`}
                    onClick={() => onReplaceClick(item)}
                />
            }
            <IconButton
                icon={<IconClose />}
                theme="borderless"
                type="tertiary"
                size="small"
                disabled={disabled}
                aria-label={`移除 ${item.name}`}
                onClick={() => onRemove(item)}
            />
        </div>
    </div>

    <style>
        .lotus-upload-file-card {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px;
            border: 1px solid var(--lotus-color-border);
            border-radius: var(--lotus-border-radius-small, 4px);
            background: var(--lotus-color-bg-1);
        }

        .lotus-upload-file-card-uploadFail,
        .lotus-upload-file-card-validateFail {
            border-color: var(--lotus-color-danger, #d94711);
        }

        .lotus-upload-file-thumbnail {
            width: 32px;
            height: 32px;
            flex-shrink: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            border-radius: var(--lotus-border-radius-small, 4px);
            background: var(--lotus-color-fill-0);
            color: var(--lotus-color-text-2);
        }

        .lotus-upload-file-thumbnail-img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .lotus-upload-file-info {
            flex: 1;
            min-width: 0;
        }

        .lotus-upload-file-name {
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            font-size: var(--lotus-font-body-size);
            color: var(--lotus-color-text-0);
        }

        .lotus-upload-file-meta {
            display: flex;
            gap: 8px;
            font-size: var(--lotus-font-caption-size);
            color: var(--lotus-color-text-2);
        }

        .lotus-upload-file-error-msg {
            color: var(--lotus-color-danger, #d94711);
        }

        .lotus-upload-file-actions {
            display: flex;
            align-items: center;
            gap: 2px;
            flex-shrink: 0;
        }

        .lotus-upload-file-card-picture {
            flex-direction: column;
            width: 96px;
        }

        .lotus-upload-file-card-picture .lotus-upload-file-thumbnail {
            width: 100%;
            height: 64px;
        }
    </style>
    </>
}

/**
 * Upload：文件上传。文件选择/校验/limit 裁剪/状态流转（wait→uploading→
 * success|uploadFail|validateFail）在 Foundation 层，真正的网络 IO
 * （XMLHttpRequest 构造、FormData 拼装、onprogress/onload/onerror 监听）
 * 完全在本组件层发起，Foundation 只提供"收到进度/成功/失败回调后如何迁移
 * 某个文件项状态"的纯状态转换方法——对齐 lotus 既有的 TreeSelect loadData
 * 异步懒加载惯例（真实 IO 副作用下沉到 .tsrx 层，Foundation 不碰网络）。
 *
 * listType 只做三档（'list'/'picture'/'none'）——Semi 没有 'picture-list'。
 * 不做并发队列/pause/abort——Semi 没有，chenzy.design spec 文档声称有但
 * 实际代码未落地，是文档超前于代码的陷阱，不作为已验证能力照搬。
 *
 * 键盘无障碍对齐 chenzy.design 已验证的增强方案（role="button"+tabIndex+
 * onKeyDown Enter/Space+aria-label），不对齐 Semi 原始的键盘空白状态
 * （Semi 拖拽区/触发按钮的 role="button" div 完全没有 onKeyDown）。
 */
export function Upload(&{
    action,
    headers,
    data,
    name = 'file',
    accept,
    multiple = false,
    limit,
    maxSize,
    minSize,
    fileList: fileListProp,
    defaultFileList = [],
    disabled = false,
    listType = 'list',
    uploadTrigger = 'auto',
    draggable = false,
    dragMainText = '点击上传文件，或将文件拖拽到此区域',
    dragSubText,
    showRetry = true,
    showReplace = false,
    withCredentials = false,
    beforeUpload,
    customRequest,
    onChange,
    onSuccess,
    onError,
    onProgress,
    onRemove,
    onRetry,
    onExceed,
    onAcceptInvalid,
    'aria-label': ariaLabel,
    style,
    class: className,
}: UploadProps) @{
    const isControlled = fileListProp !== undefined;

    let &[state] = track<UploadState>({
        fileList: isControlled ? fileListProp! : defaultFileList,
        dragAreaStatus: 'default',
    });

    const foundation = new UploadFoundation(
        {
            getState: () => untrack(() => state),
            setState: (patch: Partial<UploadState>) => { state = { ...untrack(() => state), ...patch }; },
        },
        { accept, maxSize, minSize, limit, uploadTrigger },
    );

    effect(() => {
        if (fileListProp === undefined) return;
        untrack(() => foundation.syncFileList(fileListProp!));
    });

    function emitChange() {
        onChange?.(untrack(() => state).fileList);
    }

    let inputNode: HTMLInputElement | null = null;
    let replaceInputNode: HTMLInputElement | null = null;
    let replaceTargetUid: string | null = null;

    function startXhr(item: FileItem) {
        if (!item.fileInstance) return;
        const args: CustomRequestArgs = {
            file: item.fileInstance,
            fileName: name,
            data: resolveData(data, item),
            headers: resolveHeaders(headers, item),
            action,
            withCredentials,
            onProgress: (percent) => {
                foundation.handleProgress(item.uid, percent);
                onProgress?.(percent, item);
                emitChange();
            },
            onSuccess: (response) => {
                foundation.handleSuccess(item.uid, response);
                onSuccess?.(response, item);
                emitChange();
            },
            onError: (message) => {
                foundation.handleError(item.uid, message);
                onError?.(message, item);
                emitChange();
            },
        };
        if (customRequest) customRequest(args);
        else xhrUpload(args);
    }

    async function maybeStartUpload(item: FileItem) {
        if (item.status !== 'uploading') return;
        if (beforeUpload && item.fileInstance) {
            const raw = await beforeUpload(item.fileInstance, item);
            const result = foundation.resolveBeforeUploadResult(raw);
            const applied = foundation.applyBeforeUploadResult(item.uid, result);
            emitChange();
            if (!applied || applied.status !== 'uploading') return;
            startXhr(applied);
            return;
        }
        startXhr(item);
    }

    function handleFilesSelected(files: File[]) {
        if (disabled || files.length === 0) return;
        const { matched, rejected } = foundation.filterByAccept(files);
        if (rejected.length > 0) onAcceptInvalid?.(rejected);
        if (matched.length === 0) return;
        const result = foundation.addFiles(matched);
        if (result.exceeded.length > 0) onExceed?.(files);
        emitChange();
        for (const item of result.added) {
            if (item.status === 'uploading') maybeStartUpload(item);
        }
    }

    function handleInputChange(event: Event) {
        const input = event.target as HTMLInputElement;
        const files = input.files ? Array.from(input.files) : [];
        handleFilesSelected(files);
        input.value = '';
    }

    function handleReplaceInputChange(event: Event) {
        const input = event.target as HTMLInputElement;
        const file = input.files?.[0];
        input.value = '';
        if (!file || !replaceTargetUid) return;
        const result = foundation.replace(replaceTargetUid, file);
        replaceTargetUid = null;
        emitChange();
        if (result && result.replaced.status === 'uploading') maybeStartUpload(result.replaced);
    }

    function openFileDialog() {
        if (disabled) return;
        inputNode?.click();
    }

    function handleTriggerKeyDown(event: KeyboardEvent) {
        if (event.key !== 'Enter' && event.key !== ' ') return;
        event.preventDefault();
        openFileDialog();
    }

    function handleDragEnter(event: DragEvent) {
        event.preventDefault();
        if (disabled) return;
        foundation.setDragAreaStatus('legal');
    }

    function handleDragOver(event: DragEvent) {
        event.preventDefault();
    }

    function handleDragLeave(event: DragEvent) {
        event.preventDefault();
        foundation.setDragAreaStatus('default');
    }

    function handleDrop(event: DragEvent) {
        event.preventDefault();
        foundation.setDragAreaStatus('default');
        if (disabled) return;
        const files = event.dataTransfer?.files ? Array.from(event.dataTransfer.files) : [];
        handleFilesSelected(files);
    }

    function handleRemove(item: FileItem) {
        const nextList = foundation.remove(item.uid);
        onRemove?.(item, nextList);
        emitChange();
    }

    function handleRetryClick(item: FileItem) {
        foundation.retry(item.uid);
        onRetry?.(item);
        emitChange();
        maybeStartUpload({ ...item, status: 'uploading', percent: 0 });
    }

    function handleReplaceClick(item: FileItem) {
        replaceTargetUid = item.uid;
        replaceInputNode?.click();
    }

    let &[classes] = track<string>(() =>
        ['lotus-upload', disabled ? 'lotus-upload-disabled' : '', className ?? ''].filter(Boolean).join(' '),
    );

    let &[dragAreaClasses] = track<string>(() =>
        ['lotus-upload-drag-area', `lotus-upload-drag-area-${state.dragAreaStatus}`].filter(Boolean).join(' '),
    );

    <>
        <div class={classes} style={style} aria-label={ariaLabel}>
            <input
                type="file"
                class="lotus-upload-input"
                accept={accept}
                multiple={multiple}
                disabled={disabled}
                tabIndex={-1}
                onChange={handleInputChange}
                ref={(node: HTMLInputElement) => { inputNode = node; }}
            />
            <input
                type="file"
                class="lotus-upload-input"
                accept={accept}
                disabled={disabled}
                tabIndex={-1}
                onChange={handleReplaceInputChange}
                ref={(node: HTMLInputElement) => { replaceInputNode = node; }}
            />

            @if (draggable) {
                <div
                    class={dragAreaClasses}
                    role="button"
                    tabIndex={disabled ? -1 : 0}
                    aria-label={ariaLabel ?? '拖拽或点击上传文件'}
                    aria-disabled={disabled}
                    onClick={openFileDialog}
                    onKeyDown={handleTriggerKeyDown}
                    onDragEnter={handleDragEnter}
                    onDragOver={handleDragOver}
                    onDragLeave={handleDragLeave}
                    onDrop={handleDrop}
                >
                    <div class="lotus-upload-drag-icon"><IconUpload /></div>
                    <div class="lotus-upload-drag-main-text">{dragMainText}</div>
                    @if (dragSubText) {
                        <div class="lotus-upload-drag-sub-text">{dragSubText}</div>
                    }
                </div>
            } @else {
                <div
                    class="lotus-upload-trigger"
                    role="button"
                    tabIndex={disabled ? -1 : 0}
                    aria-label={ariaLabel ?? '上传文件'}
                    aria-disabled={disabled}
                    onClick={openFileDialog}
                    onKeyDown={handleTriggerKeyDown}
                >
                    <IconUpload />
                    <span>上传文件</span>
                </div>
            }

            @if (listType !== 'none' && state.fileList.length > 0) {
                <div class={['lotus-upload-file-list', `lotus-upload-file-list-${listType}`].join(' ')} role="list" aria-label="已上传文件">
                    @for (const item of state.fileList; index fi; key item.uid) {
                        <FileCard
                            item={item}
                            listType={listType}
                            showRetry={showRetry}
                            showReplace={showReplace}
                            disabled={disabled}
                            onRemove={handleRemove}
                            onRetryClick={handleRetryClick}
                            onReplaceClick={handleReplaceClick}
                        />
                    }
                </div>
            }
        </div>

        <style>
            .lotus-upload {
                display: flex;
                flex-direction: column;
                gap: 12px;
            }

            .lotus-upload-input {
                display: none;
            }

            .lotus-upload-trigger {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                width: fit-content;
                padding: 6px 16px;
                border: 1px solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-small, 4px);
                background: var(--lotus-color-bg-1);
                color: var(--lotus-color-text-0);
                cursor: pointer;
            }

            .lotus-upload-trigger:hover {
                border-color: var(--lotus-color-primary);
                color: var(--lotus-color-primary);
            }

            .lotus-upload-drag-area {
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                gap: 4px;
                padding: 24px;
                border: 1px dashed var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-small, 4px);
                background: var(--lotus-color-fill-0);
                cursor: pointer;
                text-align: center;
            }

            .lotus-upload-drag-area-legal {
                border-color: var(--lotus-color-primary);
                background: var(--lotus-color-primary-light, rgba(0, 100, 250, 0.05));
            }

            .lotus-upload-drag-icon {
                font-size: 32px;
                color: var(--lotus-color-text-2);
            }

            .lotus-upload-drag-main-text {
                font-size: var(--lotus-font-body-size);
                color: var(--lotus-color-text-0);
            }

            .lotus-upload-drag-sub-text {
                font-size: var(--lotus-font-caption-size);
                color: var(--lotus-color-text-2);
            }

            .lotus-upload-file-list {
                display: flex;
                flex-direction: column;
                gap: 8px;
            }

            .lotus-upload-file-list-picture {
                flex-direction: row;
                flex-wrap: wrap;
            }

            .lotus-upload-disabled {
                opacity: 0.6;
                pointer-events: none;
            }
        </style>
    </>
}
