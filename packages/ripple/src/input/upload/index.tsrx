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
import { Modal } from '../../show/modal/index.tsrx';
import { Cropper } from '../../show/cropper/index.tsrx';
import { IconUpload, IconUploadError, IconClose, IconFile, IconRefresh } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

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

export type ValidateStatus = 'default' | 'error' | 'warning' | 'success';
export type PromptPosition = 'left' | 'right' | 'bottom';

export interface AfterUploadResult {
    autoRemove?: boolean;
    status?: FileItem['status'];
    validateMessage?: string;
    name?: string;
    url?: string;
}

/** `crop` 传对象形式时的配置（对齐 Semi CropProps）。 */
export interface CropProps {
    aspectRatio?: number;
    shape?: 'rect' | 'round' | 'roundRect';
    minZoom?: number;
    maxZoom?: number;
    zoomStep?: number;
    /** 输出图片质量，0-1，默认 0.92（对齐 Semi）。 */
    quality?: number;
    fill?: string;
    modalTitle?: string;
    modalOkText?: string;
    modalCancelText?: string;
}

export interface RenderFileItemProps {
    fileInstance?: File;
    name: string;
    percent: number;
    size: number;
    status: FileItem['status'];
    uid: string;
    url?: string;
    validateMessage?: string;
    /** 文件在当前列表中的位置（从 0 开始），对齐 Semi renderPicInfo 默认展示 index+1 编号。 */
    index: number;
    onRemove: () => void;
    onRetry: () => void;
    onReplace: () => void;
    onPreviewClick: () => void;
}

/** picture 卡片专属的自定义渲染点：`renderPicClose` 携带的参数（对齐 Semi）。 */
export interface RenderPicCloseProps {
    className: string;
    remove: () => void;
}

export interface UploadProps {
    action: string;
    headers?: UploadHeaders | ((file: FileItem) => UploadHeaders);
    data?: Record<string, unknown> | ((file: FileItem) => Record<string, unknown>);
    name?: string;
    fileName?: string;
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
    directory?: boolean;
    capture?: boolean | 'user' | 'environment';
    dragMainText?: string;
    dragSubText?: string;
    dragIcon?: any;
    /** 自定义触发区域内容，替换默认的"点击上传"按钮/拖拽区图标+文案
     * （对齐 Semi children）。传入后 draggable 模式下 dragIcon/dragMainText/
     * dragSubText 不再生效——children 完全接管拖拽区展示。 */
    children?: any;
    showRetry?: boolean;
    showReplace?: boolean;
    showClear?: boolean;
    showTooltip?: boolean;
    showPicInfo?: boolean;
    showUploadList?: boolean;
    picWidth?: string | number;
    picHeight?: string | number;
    itemStyle?: Record<string, any>;
    hotSpotLocation?: 'start' | 'end';
    prompt?: any;
    promptPosition?: PromptPosition;
    validateStatus?: ValidateStatus;
    validateMessage?: any;
    withCredentials?: boolean;
    timeout?: number;
    addOnPasting?: boolean;
    beforeUpload?: (file: File, fileItem: FileItem) => boolean | BeforeUploadResult | Promise<boolean | BeforeUploadResult>;
    beforeRemove?: (file: FileItem, fileList: FileItem[]) => boolean | Promise<boolean>;
    beforeClear?: (fileList: FileItem[]) => boolean | Promise<boolean>;
    transformFile?: (file: File) => FileItem;
    previewFile?: (props: RenderFileItemProps) => any;
    renderFileItem?: (props: RenderFileItemProps) => any;
    /** picture 类型下替换缩略图区域（对齐 Semi renderThumbnail）。 */
    renderThumbnail?: (props: RenderFileItemProps) => any;
    /** picture 类型下替换预览图标，success 状态且非 replace 模式时展示（对齐 Semi renderPicPreviewIcon）。 */
    renderPicPreviewIcon?: (props: RenderFileItemProps) => any;
    /** picture 类型下替换关闭按钮（对齐 Semi renderPicClose）。 */
    renderPicClose?: (props: RenderPicCloseProps) => any;
    /** picture 类型下替换角标信息区域，默认展示文件大小/错误信息（对齐 Semi renderPicInfo；
     * 注意 Semi 默认展示 index+1 编号，lotus 沿用自己既有的"文件大小/错误信息"默认展示，
     * 仅在传入此 prop 时切换为自定义内容，不改变既有默认行为）。 */
    renderPicInfo?: (props: RenderFileItemProps) => any;
    /** list 类型下替换默认的移除按钮操作区（对齐 Semi renderFileOperation）。 */
    renderFileOperation?: (props: RenderFileItemProps) => any;
    /** 文件列表标题区域自定义（对齐 Semi fileListTitle）：传非函数值只替换标题文案，
     * 清空按钮仍由组件渲染；传函数则完全接管整个标题区域（含清空按钮），函数携带
     * `{ fileList, onClear, clearText }`。 */
    fileListTitle?: any | ((props: { fileList: FileItem[]; onClear: () => void; clearText: string }) => any);
    customRequest?: (args: CustomRequestArgs) => void;
    onChange?: (fileList: FileItem[]) => void;
    onSuccess?: (response: unknown, file: FileItem) => void;
    onError?: (error: unknown, file: FileItem) => void;
    onProgress?: (percent: number, file: FileItem) => void;
    onRemove?: (file: FileItem, fileList: FileItem[]) => void;
    onRetry?: (file: FileItem) => void;
    onExceed?: (files: File[]) => void;
    onAcceptInvalid?: (files: File[]) => void;
    onClear?: () => void;
    onDrop?: (event: DragEvent, files: File[], fileList: FileItem[]) => void;
    onFileChange?: (files: File[]) => void;
    onOpenFileDialog?: () => void;
    onPreviewClick?: (file: FileItem) => void;
    onSizeError?: (file: FileItem, fileList: FileItem[]) => void;
    onPastingError?: (error: Error) => void;
    afterUpload?: (args: { response: unknown; file: FileItem; fileList: FileItem[] }) => AfterUploadResult | void;
    /** 开启图片裁剪：选中/拖入/粘贴的图片文件会先弹出裁剪 Modal，确认后用裁剪结果
     * 替换原文件再继续走正常上传流程（对齐 Semi crop）。传 true 用默认配置，
     * 传对象自定义裁剪框形状/缩放范围/输出质量等。多张图片按选中顺序逐张裁剪，
     * 非图片文件不受影响、与裁剪结果一起在队列处理完后统一提交。 */
    crop?: boolean | CropProps;
    /** 每批文件里第一张图片弹出裁剪 Modal 前调用，返回 false（或 reject）则整批文件
     * 跳过裁剪直接走正常上传（对齐 Semi beforeCrop）。 */
    beforeCrop?: (file: File, fileList: File[]) => boolean | Promise<boolean>;
    /** 裁剪流程出错时触发（对齐 Semi onCropError）。 */
    onCropError?: (error: Error) => void;
    /** 透传给裁剪 Modal 的额外 props（对齐 Semi cropModalProps）。 */
    cropModalProps?: Record<string, any>;
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

/** 内置 XHR 上传：FormData 拼装 + headers 设置 + onprogress/onload/onerror 监听。
 * timeout 真正接到 xhr.timeout——Semi 声明了这个 prop 但从未接入 xhr（dead
 * prop），这里主动修正。 */
function xhrUpload(args: CustomRequestArgs, locale: import('@lotus/locale').LocaleShape, timeout?: number) {
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
    if (timeout !== undefined) xhr.timeout = timeout;
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
            args.onError(locale.Upload.uploadFail(xhr.status));
        }
    };
    xhr.onerror = () => args.onError(locale.Upload.networkError);
    xhr.ontimeout = () => args.onError(locale.Upload.networkError);
    xhr.send(formData);
}

interface FileCardProps {
    item: FileItem;
    index: number;
    listType: ListType;
    showRetry: boolean;
    showReplace: boolean;
    showTooltip: boolean;
    showPicInfo: boolean;
    picWidth?: string | number;
    picHeight?: string | number;
    itemStyle?: Record<string, any>;
    hotSpotLocation: 'start' | 'end';
    disabled: boolean;
    renderFileItem?: (props: RenderFileItemProps) => any;
    previewFile?: (props: RenderFileItemProps) => any;
    /** picture 类型下替换缩略图区域（对齐 Semi renderThumbnail）。 */
    renderThumbnail?: (props: RenderFileItemProps) => any;
    /** picture 类型下替换预览图标（success 状态且非 replace 模式时展示，对齐 Semi renderPicPreviewIcon）。 */
    renderPicPreviewIcon?: (props: RenderFileItemProps) => any;
    /** picture 类型下替换关闭按钮（对齐 Semi renderPicClose）。 */
    renderPicClose?: (props: RenderPicCloseProps) => any;
    /** picture 类型下替换角标信息，默认展示 index+1 编号（对齐 Semi renderPicInfo）。 */
    renderPicInfo?: (props: RenderFileItemProps) => any;
    /** list 类型下替换默认的移除按钮操作区（对齐 Semi renderFileOperation）。 */
    renderFileOperation?: (props: RenderFileItemProps) => any;
    onRemove: (item: FileItem) => void;
    onRetryClick: (item: FileItem) => void;
    onReplaceClick: (item: FileItem) => void;
    onPreviewClick: (item: FileItem) => void;
}

function toRenderFileItemProps(item: FileItem, index: number, handlers: {
    onRemove: () => void;
    onRetry: () => void;
    onReplace: () => void;
    onPreviewClick: () => void;
}): RenderFileItemProps {
    return {
        fileInstance: item.fileInstance,
        name: item.name,
        percent: item.percent,
        size: item.size,
        status: item.status,
        uid: item.uid,
        url: item.url,
        validateMessage: item.validateMessage,
        index,
        ...handlers,
    };
}

function statusLabel(status: FileItem['status'], locale: import('@lotus/locale').LocaleShape): string {
    if (status === 'uploadFail') return locale.Upload.statusUploadFail;
    if (status === 'validateFail') return locale.Upload.statusValidateFail;
    if (status === 'success') return locale.Upload.statusSuccess;
    if (status === 'uploading') return locale.Upload.statusUploading;
    return locale.Upload.statusWaiting;
}

function FileCard(&{
    item, index, listType, showRetry, showReplace, showTooltip, showPicInfo, picWidth, picHeight, itemStyle,
    hotSpotLocation, disabled, renderFileItem, previewFile, renderThumbnail, renderPicPreviewIcon, renderPicClose,
    renderPicInfo, renderFileOperation, onRemove, onRetryClick, onReplaceClick, onPreviewClick,
}: FileCardProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    const renderProps = toRenderFileItemProps(item, index, {
        onRemove: () => onRemove(item),
        onRetry: () => onRetryClick(item),
        onReplace: () => onReplaceClick(item),
        onPreviewClick: () => onPreviewClick(item),
    });

    <>
    @if (renderFileItem) {
        <div class="lotus-upload-file-card-custom" role="listitem" style={itemStyle}>
            <span style="display:contents">{renderFileItem(renderProps)}</span>
        </div>
    } @else {
    <div
        class={['lotus-upload-file-card', `lotus-upload-file-card-${listType}`, `lotus-upload-file-card-${item.status}`].join(' ')}
        role="listitem"
        style={{ ...(picWidth !== undefined ? { width: typeof picWidth === 'number' ? `${picWidth}px` : picWidth } : {}), ...itemStyle }}
    >
        <div
            class="lotus-upload-file-thumbnail"
            style={picHeight !== undefined ? { height: typeof picHeight === 'number' ? `${picHeight}px` : picHeight } : undefined}
            title={showTooltip ? item.name : undefined}
            onClick={() => onPreviewClick(item)}
        >
            <>
            @if (renderThumbnail) {
                <span style="display:contents">{renderThumbnail(renderProps)}</span>
            } @else if (previewFile) {
                <span class="lotus-upload-preview-slot" style="display:contents">{previewFile(renderProps)}</span>
            } @else if (isImageFile(item) && item.fileInstance) {
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
            @if (listType === 'picture' && renderPicPreviewIcon && item.status === 'success' && !showReplace) {
                <span class="lotus-upload-picture-preview-icon" style="display:contents">{renderPicPreviewIcon(renderProps)}</span>
            }
            </>
        </div>
        <div class="lotus-upload-file-info">
            <div class="lotus-upload-file-name" title={showTooltip ? item.name : undefined}>{item.name}</div>
            @if (listType === 'picture' && showPicInfo && renderPicInfo) {
                <span style="display:contents">{renderPicInfo(renderProps)}</span>
            } @else if (listType !== 'picture' || showPicInfo) {
                <div class="lotus-upload-file-meta">
                    <span class="lotus-upload-file-size">{formatFileSize(item.size)}</span>
                    @if (item.status === 'uploadFail' || item.status === 'validateFail') {
                        <span class="lotus-upload-file-error-msg">{item.validateMessage ?? statusLabel(item.status, locale)}</span>
                    }
                </div>
            }
            @if (item.status === 'uploading') {
                <Progress
                    percent={item.percent}
                    type={listType === 'picture' ? 'circle' : 'line'}
                    size="small"
                    aria-label={locale.Upload.progress(item.name)}
                />
            }
        </div>
        <div class={['lotus-upload-file-actions', `lotus-upload-file-actions-${hotSpotLocation}`].join(' ')}>
            @if (showRetry && item.status === 'uploadFail') {
                <IconButton
                    icon={<IconRefresh />}
                    theme="borderless"
                    type="tertiary"
                    size="small"
                    disabled={disabled}
                    aria-label={locale.Upload.retry(item.name)}
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
                    aria-label={locale.Upload.replace(item.name)}
                    onClick={() => onReplaceClick(item)}
                />
            }
            @if (listType === 'picture' && renderPicClose) {
                <span style="display:contents">{renderPicClose({ className: 'lotus-upload-file-close-custom', remove: () => onRemove(item) })}</span>
            } @else if (listType !== 'picture' && renderFileOperation) {
                <span style="display:contents">{renderFileOperation(renderProps)}</span>
            } @else {
                <IconButton
                    icon={<IconClose />}
                    theme="borderless"
                    type="tertiary"
                    size="small"
                    disabled={disabled}
                    aria-label={locale.Upload.remove(item.name)}
                    onClick={() => onRemove(item)}
                />
            }
        </div>
    </div>
    }

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

        .lotus-upload-file-actions-start {
            order: -1;
        }

        .lotus-upload-file-card-custom {
            display: contents;
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
    fileName,
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
    directory = false,
    capture,
    dragMainText,
    dragSubText,
    dragIcon,
    children,
    showRetry = true,
    showReplace = false,
    showClear = false,
    showTooltip = true,
    showPicInfo = false,
    showUploadList = true,
    picWidth,
    picHeight,
    itemStyle,
    hotSpotLocation = 'end',
    prompt,
    promptPosition = 'right',
    validateStatus = 'default',
    validateMessage,
    withCredentials = false,
    timeout,
    addOnPasting = false,
    beforeUpload,
    beforeRemove,
    beforeClear,
    transformFile,
    previewFile,
    renderFileItem,
    renderThumbnail,
    renderPicPreviewIcon,
    renderPicClose,
    renderPicInfo,
    renderFileOperation,
    fileListTitle,
    customRequest,
    onChange,
    onSuccess,
    onError,
    onProgress,
    onRemove,
    onRetry,
    onExceed,
    onAcceptInvalid,
    onClear,
    onDrop,
    onFileChange,
    onOpenFileDialog,
    onPreviewClick,
    onSizeError,
    onPastingError,
    afterUpload,
    crop,
    beforeCrop,
    onCropError,
    cropModalProps,
    'aria-label': ariaLabel,
    style,
    class: className,
}: UploadProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

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

    // 受控模式下 state.fileList 不再随本地操作更新（只由 fileListProp 同步过来），
    // 因此 onChange 载荷必须显式传入本次操作算出的新列表，不能读 state——否则
    // 受控模式下 onChange 会永远带着"操作之前"的旧值，父组件即使想接受这次变化
    // 也拿不到正确的新列表。
    function emitChange(fileList: FileItem[]) {
        onChange?.(fileList);
    }

    let inputNode: HTMLInputElement | null = null;
    let replaceInputNode: HTMLInputElement | null = null;
    let replaceTargetUid: string | null = null;

    // crop 状态机（对齐 Semi handleCropFiles/handleCropOk/handleCropCancel）：
    // 选中的图片文件先逐张过 Cropper Modal，确认后用裁剪结果（保留原文件名/
    // lastModified）替换原文件，非图片文件原样保留，队列耗尽后把"裁剪结果 +
    // 非图片文件"合并成一批，一次性走 handleFilesSelected/replace 正常流程。
    // 取消裁剪则整批（含已裁剪但未提交的、队列里剩下的、非图片文件）全部丢弃，
    // 不触发任何上传——对齐 Semi closeCropperAndReset 的语义。
    let &[cropState] = track<{
        visible: boolean;
        currentFile: File | null;
        currentSrc: string;
        pendingImages: File[];
        nonImageFiles: File[];
        croppedFiles: File[];
        isReplaceOperation: boolean;
    }>({
        visible: false,
        currentFile: null,
        currentSrc: '',
        pendingImages: [],
        nonImageFiles: [],
        croppedFiles: [],
        isReplaceOperation: false,
    });
    let cropperGetCanvas: (() => HTMLCanvasElement | null) | null = null;

    function isImageFileNative(file: File): boolean {
        return file.type.startsWith('image/');
    }

    function dispatchUpload(files: File[], isReplaceOperation: boolean) {
        if (isReplaceOperation) {
            const file = files[0];
            if (file) applyReplace(file);
        } else {
            handleFilesSelected(files);
        }
    }

    async function shouldCropFile(file: File, files: File[]): Promise<boolean> {
        if (!beforeCrop) return true;
        try {
            const result = await beforeCrop(file, files);
            return result !== false;
        } catch (error) {
            onCropError?.(error as Error);
            return false;
        }
    }

    async function maybeStartCrop(files: File[], isReplaceOperation: boolean): Promise<boolean> {
        if (!crop) return false;
        const imageFiles = files.filter(isImageFileNative);
        const nonImageFiles = files.filter((f) => !isImageFileNative(f));
        if (imageFiles.length === 0) return false;

        const shouldCrop = await shouldCropFile(imageFiles[0]!, files);
        if (!shouldCrop) return false;

        const queue = isReplaceOperation ? [imageFiles[0]!] : imageFiles;
        const [first, ...rest] = queue;
        if (!first) return false;
        cropState = {
            visible: true,
            currentFile: first,
            currentSrc: URL.createObjectURL(first),
            pendingImages: rest,
            nonImageFiles: isReplaceOperation ? [] : nonImageFiles,
            croppedFiles: [],
            isReplaceOperation,
        };
        return true;
    }

    function closeCropperAndReset() {
        const cur = untrack(() => cropState);
        if (cur.currentSrc) URL.revokeObjectURL(cur.currentSrc);
        cropState = {
            visible: false,
            currentFile: null,
            currentSrc: '',
            pendingImages: [],
            nonImageFiles: [],
            croppedFiles: [],
            isReplaceOperation: false,
        };
    }

    async function handleCropOk() {
        const cur = untrack(() => cropState);
        try {
            const canvas = cropperGetCanvas?.();
            if (!canvas || !cur.currentFile) throw new Error('Cropper instance not found');
            const cropConfig = typeof crop === 'object' ? crop : {};
            const quality = cropConfig.quality ?? 0.92;
            const type = cur.currentFile.type || 'image/png';
            const blob = await new Promise<Blob>((resolve, reject) => {
                canvas.toBlob((b) => (b ? resolve(b) : reject(new Error('Failed to create blob'))), type, quality);
            });
            const croppedFile = new File([blob], cur.currentFile.name, { type, lastModified: cur.currentFile.lastModified });
            const nextCropped = [...cur.croppedFiles, croppedFile];

            if (cur.pendingImages.length > 0) {
                const [next, ...rest] = cur.pendingImages;
                if (cur.currentSrc) URL.revokeObjectURL(cur.currentSrc);
                cropState = { ...cur, currentFile: next!, currentSrc: URL.createObjectURL(next!), pendingImages: rest, croppedFiles: nextCropped };
                return;
            }

            closeCropperAndReset();
            dispatchUpload([...nextCropped, ...cur.nonImageFiles], cur.isReplaceOperation);
        } catch (error) {
            onCropError?.(error as Error);
        }
    }

    function handleCropCancel() {
        closeCropperAndReset();
    }

    function startXhr(item: FileItem) {
        if (!item.fileInstance) return;
        const args: CustomRequestArgs = {
            file: item.fileInstance,
            fileName: fileName ?? name,
            data: resolveData(data, item),
            headers: resolveHeaders(headers, item),
            action,
            withCredentials,
            onProgress: (percent) => {
                const result = foundation.handleProgress(item.uid, percent, isControlled);
                onProgress?.(percent, item);
                if (result) emitChange(result.fileList);
            },
            onSuccess: (response) => {
                const afterResult = afterUpload?.({ response, file: item, fileList: untrack(() => state.fileList) }) ?? undefined;
                const result = foundation.handleSuccess(item.uid, response, isControlled, afterResult as any);
                onSuccess?.(response, item);
                if (result) emitChange(result.fileList);
            },
            onError: (message) => {
                const result = foundation.handleError(item.uid, message, isControlled);
                onError?.(message, item);
                if (result) emitChange(result.fileList);
            },
        };
        if (customRequest) customRequest(args);
        else xhrUpload(args, locale, timeout);
    }

    async function maybeStartUpload(item: FileItem) {
        if (item.status !== 'uploading') return;
        if (beforeUpload && item.fileInstance) {
            const raw = await beforeUpload(item.fileInstance, item);
            const result = foundation.resolveBeforeUploadResult(raw);
            const applied = foundation.applyBeforeUploadResult(item.uid, result, isControlled);
            if (applied) emitChange(applied.fileList);
            if (!applied || applied.item.status !== 'uploading') return;
            startXhr(applied.item);
            return;
        }
        startXhr(item);
    }

    function handleFilesSelected(files: File[]) {
        if (disabled || files.length === 0) return;
        onFileChange?.(files);
        const { matched, rejected } = foundation.filterByAccept(files);
        if (rejected.length > 0) onAcceptInvalid?.(rejected);
        if (matched.length === 0) return;
        const result = foundation.addFiles(matched, isControlled, transformFile);
        if (result.exceeded.length > 0) onExceed?.(files);
        emitChange(result.fileList);
        for (const invalid of result.sizeInvalid) onSizeError?.(invalid, result.fileList);
        for (const item of result.added) {
            if (item.status === 'uploading') maybeStartUpload(item);
        }
    }

    async function handleFilesSelectedMaybeCrop(files: File[]) {
        if (disabled || files.length === 0) return;
        const cropped = await maybeStartCrop(files, false);
        if (!cropped) handleFilesSelected(files);
    }

    function applyReplace(file: File) {
        if (!replaceTargetUid) return;
        const result = foundation.replace(replaceTargetUid, file, isControlled);
        replaceTargetUid = null;
        if (result) emitChange(result.fileList);
        if (result && result.replaced.status === 'uploading') maybeStartUpload(result.replaced);
    }

    function handleInputChange(event: Event) {
        const input = event.target as HTMLInputElement;
        const files = input.files ? Array.from(input.files) : [];
        handleFilesSelectedMaybeCrop(files);
        input.value = '';
    }

    async function handleReplaceInputChange(event: Event) {
        const input = event.target as HTMLInputElement;
        const file = input.files?.[0];
        input.value = '';
        if (!file || !replaceTargetUid) return;
        const cropped = await maybeStartCrop([file], true);
        if (!cropped) applyReplace(file);
    }

    function openFileDialog() {
        if (disabled) return;
        onOpenFileDialog?.();
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
        onDrop?.(event, files, untrack(() => state.fileList));
        handleFilesSelectedMaybeCrop(files);
    }

    async function handleRemove(item: FileItem) {
        if (beforeRemove) {
            const allowed = await beforeRemove(item, untrack(() => state.fileList));
            if (allowed === false) return;
        }
        const nextList = foundation.remove(item.uid, isControlled);
        onRemove?.(item, nextList);
        emitChange(nextList);
    }

    async function handleClear() {
        const currentList = untrack(() => state.fileList);
        if (beforeClear) {
            const allowed = await beforeClear(currentList);
            if (allowed === false) return;
        }
        const nextList = foundation.clear(isControlled);
        onClear?.();
        emitChange(nextList);
    }

    function handleRetryClick(item: FileItem) {
        const result = foundation.retry(item.uid, isControlled);
        onRetry?.(item);
        if (result) emitChange(result.fileList);
        maybeStartUpload({ ...item, status: 'uploading', percent: 0 });
    }

    function handleReplaceClick(item: FileItem) {
        replaceTargetUid = item.uid;
        replaceInputNode?.click();
    }

    function handlePreviewClick(item: FileItem) {
        onPreviewClick?.(item);
    }

    effect(() => {
        if (!addOnPasting) return;
        const handlePaste = (event: ClipboardEvent) => {
            if (untrack(() => disabled)) return;
            const items = event.clipboardData?.items;
            if (!items) return;
            const files: File[] = [];
            for (const clipItem of Array.from(items)) {
                if (clipItem.kind !== 'file') continue;
                const file = clipItem.getAsFile();
                if (file) files.push(file);
            }
            if (files.length === 0) return;
            handleFilesSelectedMaybeCrop(files);
        };
        document.body.addEventListener('paste', handlePaste as EventListener);
        return () => document.body.removeEventListener('paste', handlePaste as EventListener);
    });

    let &[classes] = track<string>(() =>
        ['lotus-upload', `lotus-upload-validate-${validateStatus}`, disabled ? 'lotus-upload-disabled' : '', className ?? ''].filter(Boolean).join(' '),
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
                capture={capture === true ? true : capture || undefined}
                tabIndex={-1}
                onChange={handleInputChange}
                ref={(node: HTMLInputElement) => {
                    inputNode = node;
                    if (directory) {
                        node.setAttribute('webkitdirectory', '');
                        node.setAttribute('directory', '');
                    }
                }}
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

            @if (promptPosition === 'left' && prompt) {
                <div class="lotus-upload-prompt lotus-upload-prompt-left">{prompt}</div>
            }

            <div class="lotus-upload-trigger-row">
                @if (draggable) {
                    <div
                        class={dragAreaClasses}
                        role="button"
                        tabIndex={disabled ? -1 : 0}
                        aria-label={ariaLabel ?? locale.Upload.dragAreaLabel}
                        aria-disabled={disabled}
                        onClick={openFileDialog}
                        onKeyDown={handleTriggerKeyDown}
                        onDragEnter={handleDragEnter}
                        onDragOver={handleDragOver}
                        onDragLeave={handleDragLeave}
                        onDrop={handleDrop}
                    >
                        @if (children) {
                            <span style="display:contents">{children}</span>
                        } @else {
                            <>
                            <div class="lotus-upload-drag-icon">
                                @if (dragIcon) {
                                    <span style="display:contents">{dragIcon}</span>
                                } @else {
                                    <IconUpload />
                                }
                            </div>
                            <div class="lotus-upload-drag-main-text">{dragMainText ?? locale.Upload.dragMainText}</div>
                            @if (dragSubText) {
                                <div class="lotus-upload-drag-sub-text">{dragSubText}</div>
                            }
                            </>
                        }
                    </div>
                } @else {
                    <div
                        class="lotus-upload-trigger"
                        role="button"
                        tabIndex={disabled ? -1 : 0}
                        aria-label={ariaLabel ?? locale.Upload.uploadButton}
                        aria-disabled={disabled}
                        onClick={openFileDialog}
                        onKeyDown={handleTriggerKeyDown}
                    >
                        @if (children) {
                            <span style="display:contents">{children}</span>
                        } @else {
                            <>
                            <IconUpload />
                            <span>{locale.Upload.uploadButton}</span>
                            </>
                        }
                    </div>
                }
                @if (promptPosition === 'right' && prompt) {
                    <div class="lotus-upload-prompt lotus-upload-prompt-right">{prompt}</div>
                }
            </div>

            @if (promptPosition === 'bottom' && prompt) {
                <div class="lotus-upload-prompt lotus-upload-prompt-bottom">{prompt}</div>
            }

            @if (validateStatus === 'error' && validateMessage) {
                <div class="lotus-upload-validate-message">{validateMessage}</div>
            }

            @if (showUploadList && listType !== 'none' && state.fileList.length > 0) {
                <>
                <div class="lotus-upload-file-list-header">
                    @if (typeof fileListTitle === 'function') {
                        <span style="display:contents">{fileListTitle({ fileList: state.fileList, onClear: handleClear, clearText: locale.Upload.clear })}</span>
                    } @else {
                        <>
                        <span class="lotus-upload-file-list-title">{fileListTitle ?? locale.Upload.fileListLabel}</span>
                        @if (showClear) {
                            <IconButton
                                icon={<IconClose />}
                                theme="borderless"
                                type="tertiary"
                                size="small"
                                disabled={disabled}
                                aria-label={locale.Upload.clear}
                                onClick={handleClear}
                            />
                        }
                        </>
                    }
                </div>
                <div class={['lotus-upload-file-list', `lotus-upload-file-list-${listType}`].join(' ')} role="list" aria-label={locale.Upload.fileListLabel}>
                    @for (const item of state.fileList; index fi; key item.uid) {
                        <FileCard
                            item={item}
                            index={fi}
                            listType={listType}
                            showRetry={showRetry}
                            showReplace={showReplace}
                            showTooltip={showTooltip}
                            showPicInfo={showPicInfo}
                            picWidth={picWidth}
                            picHeight={picHeight}
                            itemStyle={itemStyle}
                            hotSpotLocation={hotSpotLocation}
                            disabled={disabled}
                            renderFileItem={renderFileItem}
                            previewFile={previewFile}
                            renderThumbnail={renderThumbnail}
                            renderPicPreviewIcon={renderPicPreviewIcon}
                            renderPicClose={renderPicClose}
                            renderPicInfo={renderPicInfo}
                            renderFileOperation={renderFileOperation}
                            onRemove={handleRemove}
                            onRetryClick={handleRetryClick}
                            onReplaceClick={handleReplaceClick}
                            onPreviewClick={handlePreviewClick}
                        />
                    }
                </div>
                </>
            }
        </div>

        @if (crop) {
            <Modal
                {...(cropModalProps ?? {})}
                width={cropModalProps?.width ?? 600}
                height={cropModalProps?.height ?? '500px'}
                title={cropModalProps?.title ?? (typeof crop === 'object' ? crop.modalTitle : undefined) ?? locale.Upload.cropTitle}
                visible={cropState.visible}
                onOk={handleCropOk}
                onCancel={handleCropCancel}
                okText={cropModalProps?.okText ?? (typeof crop === 'object' ? crop.modalOkText : undefined) ?? locale.Upload.cropOk}
                cancelText={cropModalProps?.cancelText ?? (typeof crop === 'object' ? crop.modalCancelText : undefined) ?? locale.Upload.cropCancel}
                bodyStyle={{ height: '400px', ...(cropModalProps?.bodyStyle ?? {}) }}
            >
                @if (cropState.currentSrc) {
                    <Cropper
                        src={cropState.currentSrc}
                        shape={typeof crop === 'object' ? crop.shape : undefined}
                        aspectRatio={typeof crop === 'object' ? crop.aspectRatio : undefined}
                        minZoom={typeof crop === 'object' ? crop.minZoom : undefined}
                        maxZoom={typeof crop === 'object' ? crop.maxZoom : undefined}
                        zoomStep={typeof crop === 'object' ? crop.zoomStep : undefined}
                        fill={typeof crop === 'object' ? crop.fill : undefined}
                        style={{ width: '100%', height: '100%' }}
                        getCropperApi={(api) => { cropperGetCanvas = api.getCropperCanvas; }}
                    />
                }
            </Modal>
        }

        <style>
            .lotus-upload {
                display: flex;
                flex-direction: column;
                gap: 12px;
            }

            .lotus-upload-input {
                display: none;
            }

            .lotus-upload-trigger-row {
                display: flex;
                align-items: center;
                gap: 12px;
            }

            .lotus-upload-prompt {
                font-size: var(--lotus-font-caption-size);
                color: var(--lotus-color-text-2);
            }

            .lotus-upload-validate-error .lotus-upload-trigger,
            .lotus-upload-validate-error .lotus-upload-drag-area {
                border-color: var(--lotus-color-danger, #d94711);
            }

            .lotus-upload-validate-message {
                font-size: var(--lotus-font-caption-size);
                color: var(--lotus-color-danger, #d94711);
            }

            .lotus-upload-file-list-header {
                display: flex;
                align-items: center;
                justify-content: space-between;
            }

            .lotus-upload-file-list-title {
                font-size: var(--lotus-font-caption-size);
                color: var(--lotus-color-text-2);
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
