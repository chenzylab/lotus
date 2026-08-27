import { track, effect, untrack } from 'ripple';
import {
    computeInitialImageState,
    computeInitialCropperBox,
    resizeImageState,
    resizeCropperBox,
    zoomAtPoint,
    nextWheelZoom,
    moveParamByDir,
    resizeCornerFree,
    rangeForAspectResize,
    resizeCornerAspect,
    flipCornerDir,
    moveCropperBox,
    moveImage,
    computeCropRegion,
    clampCropRegionToCanvas,
    type Point,
    type Size,
    type CropperImageState,
    type CropperImageMeta,
    type CropperBoxState,
    type CropperCornerDir,
    type CropperInteractionMode,
} from '@lotus/foundation/show/cropper';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export type { CropperCornerDir, CropperInteractionMode };
export type CropperShape = 'rect' | 'round' | 'roundRect';

export interface CropperApi {
    /** 命令式取当前裁切结果的 canvas（对齐 Semi 的 ref.current.getCropperCanvas()；
     * Ripple 没有 ref 转发到自定义实例的机制，改用 getCropperApi 回调获取，与 Form 的 getFormApi 同一模式）。 */
    getCropperCanvas: () => HTMLCanvasElement | null;
}

export interface CropperProps {
    src: string;
    shape?: CropperShape;
    aspectRatio?: number;
    defaultAspectRatio?: number;
    zoom?: number;
    onZoomChange?: (zoom: number) => void;
    rotate?: number;
    showResizeBox?: boolean;
    fill?: string;
    maxZoom?: number;
    minZoom?: number;
    zoomStep?: number;
    /** Semi 没有声明式裁切回调（只有命令式 getCropperCanvas 方法），
     * lotus 主动增加：裁切框/缩放/旋转任一变化后即时触发，携带一次性算好的 canvas。 */
    onCrop?: (canvas: HTMLCanvasElement) => void;
    getCropperApi?: (api: CropperApi) => void;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

const CORNER_DIRS: CropperCornerDir[] = ['tl', 'tm', 'tr', 'ml', 'mr', 'bl', 'br', 'bm'];
const KEYBOARD_STEP = 4;

function containerSize(node: HTMLElement): Size {
    return { width: node.clientWidth, height: node.clientHeight };
}

export function Cropper(&{
    src,
    shape = 'rect',
    aspectRatio,
    defaultAspectRatio = 1,
    zoom: zoomProp,
    onZoomChange,
    rotate = 0,
    showResizeBox = true,
    fill = 'rgba(0,0,0,0)',
    maxZoom = 3,
    minZoom = 0.1,
    zoomStep = 0.1,
    onCrop,
    getCropperApi,
    style,
    class: className,
    'aria-label': ariaLabel,
}: CropperProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    const isZoomControlled = zoomProp !== undefined;

    let &[loaded] = track<boolean>(false);
    let &[mode] = track<CropperInteractionMode>('idle');
    let &[imgData] = track<CropperImageState>({ width: 0, height: 0, centerPoint: { x: 0, y: 0 } });
    let &[cropperBox] = track<CropperBoxState>({ width: 0, height: 0, centerPoint: { x: 0, y: 0 } });
    let &[zoom] = track<number>(zoomProp ?? 1);
    let &[containerEl] = track<HTMLElement | null>(null);
    let &[imgEl] = track<HTMLImageElement | null>(null);

    let imgMeta: CropperImageMeta = { originalWidth: 0, originalHeight: 0, scale: 1 };
    let lastContainerSize: Size = { width: 0, height: 0 };
    let dragStart: Point | null = null;
    let cornerDir: CropperCornerDir | null = null;
    let cornerParam: { paramX: number; paramY: number } = { paramX: 0, paramY: 0 };
    let cornerAspectRange: { rangeX: [number, number]; rangeY: [number, number] } | null = null;

    effect(() => {
        if (!isZoomControlled) return;
        const z = zoomProp;
        if (z === undefined || z === untrack(() => zoom)) return;
        zoom = z;
    });

    function buildCropCanvas(): HTMLCanvasElement | null {
        const img = untrack(() => imgEl);
        if (!img || !untrack(() => loaded)) return null;
        const region = computeCropRegion(untrack(() => imgData), untrack(() => cropperBox), imgMeta, untrack(() => zoom), rotate);
        const canvas = document.createElement('canvas');
        const ctx = canvas.getContext('2d');
        if (!ctx) return null;
        canvas.width = region.cropWidth;
        canvas.height = region.cropHeight;
        ctx.fillStyle = fill;
        ctx.fillRect(0, 0, region.cropWidth, region.cropHeight);
        if (!region.intersects) return canvas;

        const rotateCanvas = document.createElement('canvas');
        rotateCanvas.width = region.canvasSize.width;
        rotateCanvas.height = region.canvasSize.height;
        const rotateCtx = rotateCanvas.getContext('2d');
        if (!rotateCtx) return canvas;
        rotateCtx.fillStyle = fill;
        rotateCtx.fillRect(0, 0, region.canvasSize.width, region.canvasSize.height);
        const halfW = region.canvasSize.width / 2;
        const halfH = region.canvasSize.height / 2;
        rotateCtx.translate(halfW, halfH);
        rotateCtx.rotate((rotate * Math.PI) / 180);
        rotateCtx.translate(-halfW, -halfH);
        const imgX = (region.canvasSize.width - imgMeta.originalWidth) / 2;
        const imgY = (region.canvasSize.height - imgMeta.originalHeight) / 2;
        rotateCtx.drawImage(img, 0, 0, imgMeta.originalWidth, imgMeta.originalHeight, imgX, imgY, imgMeta.originalWidth, imgMeta.originalHeight);

        const clamped = clampCropRegionToCanvas(region);
        if (clamped.sourceWidth <= 0 || clamped.sourceHeight <= 0) return canvas;
        const pixels = rotateCtx.getImageData(clamped.sourceX, clamped.sourceY, clamped.sourceWidth, clamped.sourceHeight);
        ctx.putImageData(pixels, clamped.pasteX, clamped.pasteY);
        return canvas;
    }

    function emitCrop() {
        if (!onCrop) return;
        const canvas = buildCropCanvas();
        if (canvas) onCrop(canvas);
    }

    getCropperApi?.({ getCropperCanvas: buildCropCanvas });

    function handleContainerRef(node: HTMLElement | null) {
        if (!node) return;
        containerEl = node;

        // Ripple 把 wheel 事件默认注册为 passive:true（对齐浏览器/多数框架的滚动性能优化默认值），
        // onWheel={handleWheel} 里的 event.preventDefault() 会被浏览器静默忽略，导致页面跟着滚动。
        // Cropper 必须能阻止默认滚动去实现"滚轮缩放图片"，改为绕过合成事件系统，用 ref 直接挂原生
        // { passive: false } 监听器（踩坑 #72）。
        node.addEventListener('wheel', handleWheel, { passive: false });

        if (typeof ResizeObserver === 'undefined') {
            return () => node.removeEventListener('wheel', handleWheel);
        }
        const observer = new ResizeObserver(() => {
            const el = untrack(() => containerEl);
            if (!el || !untrack(() => loaded)) return;
            const next = containerSize(el);
            if (next.width === lastContainerSize.width && next.height === lastContainerSize.height) return;
            if (lastContainerSize.width === 0) {
                lastContainerSize = next;
                return;
            }
            const ratio = next.width / lastContainerSize.width;
            lastContainerSize = next;
            imgData = resizeImageState(untrack(() => imgData), ratio);
            imgMeta = { ...imgMeta, scale: imgMeta.scale * ratio };
            cropperBox = resizeCropperBox(untrack(() => cropperBox), ratio, next, aspectRatio);
        });
        observer.observe(node);
        return () => {
            node.removeEventListener('wheel', handleWheel);
            observer.disconnect();
        };
    }

    function handleImageLoad(event: Event) {
        const target = event.target as HTMLImageElement;
        const el = untrack(() => containerEl);
        if (!el) return;
        const container = containerSize(el);
        lastContainerSize = container;
        const { imgData: nextImgData, meta } = computeInitialImageState(target.naturalWidth, target.naturalHeight, container);
        imgMeta = meta;
        imgData = nextImgData;
        cropperBox = computeInitialCropperBox(container, aspectRatio || defaultAspectRatio);
        loaded = true;
    }

    function setZoom(next: number) {
        zoom = next;
        onZoomChange?.(next);
        emitCrop();
    }

    function handleWheel(event: WheelEvent) {
        event.preventDefault();
        const next = nextWheelZoom(untrack(() => zoom), event.deltaY, zoomStep, minZoom, maxZoom);
        if (next === null) return;
        const el = untrack(() => containerEl);
        if (!el) return;
        const rect = el.getBoundingClientRect();
        const anchor: Point = { x: event.clientX - rect.left, y: event.clientY - rect.top };
        imgData = zoomAtPoint(untrack(() => imgData), untrack(() => zoom), next, anchor);
        setZoom(next);
    }

    function handleBoxMouseDown(event: MouseEvent) {
        const target = event.target as HTMLElement;
        if (target?.dataset?.dir) return;
        event.preventDefault();
        dragStart = { x: event.clientX, y: event.clientY };
        mode = 'moving-box';
    }

    function handleCornerMouseDown(dir: CropperCornerDir) {
        return (event: MouseEvent) => {
            event.preventDefault();
            event.stopPropagation();
            cornerDir = dir;
            const el = untrack(() => containerEl);
            if (!el) return;
            const container = containerSize(el);
            if (aspectRatio) {
                cornerAspectRange = rangeForAspectResize(untrack(() => cropperBox), container, aspectRatio, dir);
                mode = 'resizing-corner-aspect';
            } else {
                cornerParam = moveParamByDir(dir);
                mode = 'resizing-corner';
            }
        };
    }

    function handleImageMouseDown(event: MouseEvent) {
        if (event.currentTarget !== event.target) return;
        event.preventDefault();
        dragStart = { x: event.clientX, y: event.clientY };
        mode = 'moving-image';
    }

    effect(() => {
        const handleMouseMove = (event: MouseEvent) => {
            const currentMode = untrack(() => mode);
            const el = untrack(() => containerEl);
            if (currentMode === 'idle' || !el) return;
            const rect = el.getBoundingClientRect();

            if (currentMode === 'moving-box' && dragStart) {
                const delta = { x: event.clientX - dragStart.x, y: event.clientY - dragStart.y };
                dragStart = { x: event.clientX, y: event.clientY };
                const container = containerSize(el);
                cropperBox = moveCropperBox(untrack(() => cropperBox), delta, container);
                return;
            }

            if (currentMode === 'moving-image' && dragStart) {
                const delta = { x: event.clientX - dragStart.x, y: event.clientY - dragStart.y };
                dragStart = { x: event.clientX, y: event.clientY };
                imgData = moveImage(untrack(() => imgData), delta);
                return;
            }

            if (currentMode === 'resizing-corner' && cornerDir) {
                const offset: Point = { x: event.clientX - rect.left, y: event.clientY - rect.top };
                const { box, param } = resizeCornerFree(untrack(() => cropperBox), cornerParam, offset);
                if (box.width === 0 && box.height === 0) {
                    cornerDir = flipCornerDir(cornerDir);
                }
                cornerParam = param;
                cropperBox = box;
                return;
            }

            if (currentMode === 'resizing-corner-aspect' && cornerDir && cornerAspectRange && aspectRatio) {
                const pointer: Point = { x: event.clientX - rect.left, y: event.clientY - rect.top };
                cropperBox = resizeCornerAspect(untrack(() => cropperBox), cornerDir, aspectRatio, cornerAspectRange, pointer);
                return;
            }
        };

        const handleMouseUp = () => {
            const currentMode = untrack(() => mode);
            if (currentMode === 'idle') return;
            mode = 'idle';
            dragStart = null;
            cornerDir = null;
            cornerAspectRange = null;
            emitCrop();
        };

        document.addEventListener('mousemove', handleMouseMove);
        document.addEventListener('mouseup', handleMouseUp);
        return () => {
            document.removeEventListener('mousemove', handleMouseMove);
            document.removeEventListener('mouseup', handleMouseUp);
        };
    });

    function handleBoxKeyDown(event: KeyboardEvent) {
        const el = untrack(() => containerEl);
        if (!el) return;
        let delta: Point | null = null;
        if (event.key === 'ArrowLeft') delta = { x: -KEYBOARD_STEP, y: 0 };
        else if (event.key === 'ArrowRight') delta = { x: KEYBOARD_STEP, y: 0 };
        else if (event.key === 'ArrowUp') delta = { x: 0, y: -KEYBOARD_STEP };
        else if (event.key === 'ArrowDown') delta = { x: 0, y: KEYBOARD_STEP };
        if (!delta) return;
        event.preventDefault();
        const container = containerSize(el);
        cropperBox = moveCropperBox(untrack(() => cropperBox), delta, container);
        emitCrop();
    }

    let &[boxStyle] = track<Record<string, any>>(() => ({
        width: `${cropperBox.width}px`,
        height: `${cropperBox.height}px`,
        transform: `translate(${cropperBox.centerPoint.x - cropperBox.width / 2}px, ${cropperBox.centerPoint.y - cropperBox.height / 2}px)`,
    }));

    let &[imgStyle] = track<Record<string, any>>(() => ({
        width: `${imgData.width}px`,
        height: `${imgData.height}px`,
        transform: `translate(${imgData.centerPoint.x - imgData.width / 2}px, ${imgData.centerPoint.y - imgData.height / 2}px) rotate(${rotate}deg)`,
    }));

    let &[maskStyle] = track<Record<string, any>>(() => {
        const clipTop = cropperBox.centerPoint.y - cropperBox.height / 2;
        const clipLeft = cropperBox.centerPoint.x - cropperBox.width / 2;
        return {
            clipPath: `polygon(0 0, 0 100%, ${clipLeft}px 100%, ${clipLeft}px ${clipTop}px, ${clipLeft + cropperBox.width}px ${clipTop}px, ${clipLeft + cropperBox.width}px ${clipTop + cropperBox.height}px, ${clipLeft}px ${clipTop + cropperBox.height}px, ${clipLeft}px 100%, 100% 100%, 100% 0)`,
        };
    });

    <>
        <div
            class={['lotus-cropper', `lotus-cropper-${shape}`, className ?? ''].filter(Boolean).join(' ')}
            style={style}
            aria-label={ariaLabel}
            ref={handleContainerRef}
        >
            <img
                class="lotus-cropper-img"
                src={src}
                draggable={false}
                style={loaded ? imgStyle : { display: 'none' }}
                ref={(node: HTMLImageElement | null) => { imgEl = node; }}
                onLoad={handleImageLoad}
                onMouseDown={handleImageMouseDown}
                onDragStart={(e: Event) => e.preventDefault()}
            />

            @if (loaded) {
                <>
                    <div class="lotus-cropper-mask" style={maskStyle} />

                    <div
                        class="lotus-cropper-box"
                        style={boxStyle}
                        role="group"
                        aria-label={locale.Cropper.cropBox}
                        tabIndex={0}
                        onMouseDown={handleBoxMouseDown}
                        onKeyDown={handleBoxKeyDown}
                    >
                        @if (showResizeBox) {
                            @for (const dir of CORNER_DIRS; key dir) {
                                <div
                                    class={`lotus-cropper-corner lotus-cropper-corner-${dir}`}
                                    data-dir={dir}
                                    onMouseDown={handleCornerMouseDown(dir)}
                                />
                            }
                        }
                    </div>
                </>
            }
        </div>

        <style>
            .lotus-cropper {
                position: relative;
                overflow: hidden;
                background: var(--lotus-color-fill-2);
                touch-action: none;
                user-select: none;
            }

            .lotus-cropper-img {
                position: absolute;
                top: 0;
                left: 0;
                transform-origin: center;
                pointer-events: auto;
            }

            .lotus-cropper-mask {
                position: absolute;
                inset: 0;
                background: rgba(0, 0, 0, 0.5);
                pointer-events: none;
            }

            .lotus-cropper-box {
                position: absolute;
                top: 0;
                left: 0;
                box-sizing: border-box;
                border: 1px solid var(--lotus-color-bg-0);
                cursor: move;
            }

            .lotus-cropper-box:focus-visible {
                outline: 2px solid var(--lotus-color-primary);
                outline-offset: 2px;
            }

            .lotus-cropper-rect .lotus-cropper-box {
                border-radius: 0;
            }

            .lotus-cropper-round .lotus-cropper-box {
                border-radius: 50%;
            }

            .lotus-cropper-roundRect .lotus-cropper-box {
                border-radius: var(--lotus-border-radius-medium);
            }

            .lotus-cropper-corner {
                position: absolute;
                width: 10px;
                height: 10px;
                background: var(--lotus-color-bg-0);
                border: 1px solid var(--lotus-color-primary);
                border-radius: 50%;
                z-index: 1;
            }

            .lotus-cropper-corner-tl { top: -5px; left: -5px; cursor: nwse-resize; }
            .lotus-cropper-corner-tm { top: -5px; left: 50%; margin-left: -5px; cursor: ns-resize; }
            .lotus-cropper-corner-tr { top: -5px; right: -5px; cursor: nesw-resize; }
            .lotus-cropper-corner-ml { top: 50%; left: -5px; margin-top: -5px; cursor: ew-resize; }
            .lotus-cropper-corner-mr { top: 50%; right: -5px; margin-top: -5px; cursor: ew-resize; }
            .lotus-cropper-corner-bl { bottom: -5px; left: -5px; cursor: nesw-resize; }
            .lotus-cropper-corner-bm { bottom: -5px; left: 50%; margin-left: -5px; cursor: ns-resize; }
            .lotus-cropper-corner-br { bottom: -5px; right: -5px; cursor: nwse-resize; }
        </style>
    </>
}
