import { track, effect, untrack, Portal } from 'ripple';
import { PreviewFoundation, initialPreviewState, type PreviewState } from '@lotus/foundation/show/image';
import { IconClose, IconPlus, IconMinus, IconRotate, IconDownload, IconChevronLeft, IconChevronRight } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export interface PreviewProps {
    srcList: string[];
    currentIndex: number;
    visible: boolean;
    onClose?: () => void;
    onIndexChange?: (index: number) => void;
    maskClosable?: boolean;
    closeOnEsc?: boolean;
    zoomStep?: number;
    minZoom?: number;
    maxZoom?: number;
    infinite?: boolean;
    zIndex?: number;
}

export function Preview(&{
    srcList,
    currentIndex,
    visible,
    onClose,
    onIndexChange,
    maskClosable = true,
    closeOnEsc = true,
    zoomStep = 0.5,
    minZoom = 0.1,
    maxZoom = 5,
    infinite = true,
    zIndex = 1050,
}: PreviewProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    let &[state] = track<PreviewState>(() => ({ ...initialPreviewState(currentIndex) }));
    let &[containerNode] = track<HTMLElement | null>(null);
    let &[isDragging] = track<boolean>(false);
    let &[dragStart] = track<{ x: number; y: number } | null>(null);

    const foundation = new PreviewFoundation(
        {
            getState: () => untrack(() => state),
            setState: (patch: Partial<PreviewState>) => { state = { ...untrack(() => state), ...patch }; },
        },
        { minZoom, maxZoom, zoomStep },
    );

    effect(() => {
        if (!visible) return;
        untrack(() => { state = { ...initialPreviewState(currentIndex) }; });
    });

    effect(() => {
        const total = srcList.length;
        const handleKeyDown = (event: KeyboardEvent) => {
            if (!untrack(() => visible)) return;
            if (closeOnEsc && event.key === 'Escape') {
                onClose?.();
                return;
            }
            if (event.key === 'ArrowLeft') {
                if (!infinite && untrack(() => state).currentIndex === 0) return;
                foundation.prev(total);
                onIndexChange?.(untrack(() => state).currentIndex);
            }
            if (event.key === 'ArrowRight') {
                if (!infinite && untrack(() => state).currentIndex === total - 1) return;
                foundation.next(total);
                onIndexChange?.(untrack(() => state).currentIndex);
            }
        };
        window.addEventListener('keydown', handleKeyDown);
        return () => window.removeEventListener('keydown', handleKeyDown);
    });

    effect(() => {
        const handleMouseMove = (event: MouseEvent) => {
            const start = untrack(() => dragStart);
            if (!start || !untrack(() => isDragging)) return;
            foundation.handleDrag(event.clientX - start.x, event.clientY - start.y);
            dragStart = { x: event.clientX, y: event.clientY };
        };
        const handleMouseUp = () => {
            isDragging = false;
            dragStart = null;
        };
        window.addEventListener('mousemove', handleMouseMove);
        window.addEventListener('mouseup', handleMouseUp);
        return () => {
            window.removeEventListener('mousemove', handleMouseMove);
            window.removeEventListener('mouseup', handleMouseUp);
        };
    });

    effect(() => {
        const node = containerNode;
        if (!node) return;
        foundation.handleContainerResize(node.clientWidth, node.clientHeight);
    });

    function handleImageLoad(event: Event) {
        const img = event.target as HTMLImageElement;
        foundation.handleImageLoaded(img.naturalWidth, img.naturalHeight);
    }

    function handleMouseDown(event: MouseEvent) {
        isDragging = true;
        dragStart = { x: event.clientX, y: event.clientY };
    }

    function handleWheel(event: WheelEvent) {
        event.preventDefault();
        foundation.handleWheel(event.deltaY);
    }

    function handlePrev() {
        const total = srcList.length;
        if (!infinite && state.currentIndex === 0) return;
        foundation.prev(total);
        onIndexChange?.(untrack(() => state).currentIndex);
    }

    function handleNext() {
        const total = srcList.length;
        if (!infinite && state.currentIndex === total - 1) return;
        foundation.next(total);
        onIndexChange?.(untrack(() => state).currentIndex);
    }

    function handleMaskClick(event: MouseEvent) {
        if (!maskClosable) return;
        // container 撑满了整个 mask 区域（flex 居中布局），点击空白处 event.target 实际是
        // container 而非 mask 本身，不能只判断 target === currentTarget；只要点击的不是
        // 图片自身（拖拽场景）、也不是被 stopPropagation 的工具栏/箭头按钮，就视为点击空白。
        const target = event.target as HTMLElement;
        if (target.classList.contains('lotus-image-preview-img')) return;
        onClose?.();
    }

    function handleDownload() {
        const src = srcList[state.currentIndex];
        if (!src) return;
        const link = document.createElement('a');
        link.href = src;
        link.download = src.split('/').pop() ?? 'image';
        link.click();
    }

    let &[currentSrc] = track<string>(() => srcList[state.currentIndex] ?? '');
    let &[imageStyle] = track<Record<string, any>>(() => ({
        transform: `translate(${state.translate.x}px, ${state.translate.y}px) rotate(${state.rotation}deg) scale(${state.zoom})`,
        cursor: isDragging ? 'grabbing' : 'grab',
    }));
    let &[hasMultiple] = track<boolean>(() => srcList.length > 1);

    <>
        @if (visible) {
            <Portal target={typeof document !== 'undefined' ? document.body : null}>
                <div
                    class="lotus-image-preview-mask"
                    style={{ zIndex }}
                    role="dialog"
                    aria-modal="true"
                    onClick={handleMaskClick}
                >
                    <div
                        class="lotus-image-preview-container"
                        ref={(node: HTMLElement) => { containerNode = node; }}
                        onWheel={handleWheel}
                    >
                        <img
                            class="lotus-image-preview-img"
                            src={currentSrc}
                            style={imageStyle}
                            onLoad={handleImageLoad}
                            onMouseDown={handleMouseDown}
                            draggable={false}
                        />
                    </div>

                    @if (hasMultiple) {
                        <button type="button" class="lotus-image-preview-arrow lotus-image-preview-arrow-left" aria-label={locale.ImagePreview.prev} onClick={(e: MouseEvent) => { e.stopPropagation(); handlePrev(); }}>
                            <IconChevronLeft />
                        </button>
                    }
                    @if (hasMultiple) {
                        <button type="button" class="lotus-image-preview-arrow lotus-image-preview-arrow-right" aria-label={locale.ImagePreview.next} onClick={(e: MouseEvent) => { e.stopPropagation(); handleNext(); }}>
                            <IconChevronRight />
                        </button>
                    }

                    <div class="lotus-image-preview-toolbar" onClick={(e: MouseEvent) => e.stopPropagation()}>
                        <button type="button" class="lotus-image-preview-tool-btn" aria-label={locale.ImagePreview.zoomIn} onClick={() => foundation.zoomIn()}>
                            <IconPlus />
                        </button>
                        <button type="button" class="lotus-image-preview-tool-btn" aria-label={locale.ImagePreview.zoomOut} onClick={() => foundation.zoomOut()}>
                            <IconMinus />
                        </button>
                        <button type="button" class="lotus-image-preview-tool-btn" aria-label={locale.ImagePreview.rotate} onClick={() => foundation.rotateRight()}>
                            <IconRotate />
                        </button>
                        <button type="button" class="lotus-image-preview-tool-btn" aria-label={locale.ImagePreview.download} onClick={handleDownload}>
                            <IconDownload />
                        </button>
                        <button type="button" class="lotus-image-preview-tool-btn" aria-label={locale.ImagePreview.close} onClick={() => onClose?.()}>
                            <IconClose />
                        </button>
                    </div>

                    @if (hasMultiple) {
                        <div class="lotus-image-preview-indicator">{state.currentIndex + 1} / {srcList.length}</div>
                    }
                </div>
            </Portal>
        }

        <style>
            .lotus-image-preview-mask {
                position: fixed;
                inset: 0;
                background: rgba(0, 0, 0, 0.65);
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .lotus-image-preview-container {
                width: 100%;
                height: 100%;
                display: flex;
                align-items: center;
                justify-content: center;
                overflow: hidden;
            }

            .lotus-image-preview-img {
                max-width: 90vw;
                max-height: 90vh;
                transition: transform 0.1s ease-out;
                user-select: none;
            }

            .lotus-image-preview-arrow {
                position: absolute;
                top: 50%;
                transform: translateY(-50%);
                display: flex;
                align-items: center;
                justify-content: center;
                width: 40px;
                height: 40px;
                border-radius: var(--lotus-border-radius-circle);
                background: rgba(255, 255, 255, 0.15);
                color: #fff;
                border: none;
                cursor: pointer;
                font-size: 20px;
            }

            .lotus-image-preview-arrow:hover {
                background: rgba(255, 255, 255, 0.3);
            }

            .lotus-image-preview-arrow-left {
                left: var(--lotus-spacing-loose);
            }

            .lotus-image-preview-arrow-right {
                right: var(--lotus-spacing-loose);
            }

            .lotus-image-preview-toolbar {
                position: absolute;
                bottom: var(--lotus-spacing-loose);
                left: 50%;
                transform: translateX(-50%);
                display: flex;
                gap: var(--lotus-spacing-tight);
                padding: var(--lotus-spacing-tight);
                border-radius: var(--lotus-border-radius-medium);
                background: rgba(0, 0, 0, 0.5);
            }

            .lotus-image-preview-tool-btn {
                display: flex;
                align-items: center;
                justify-content: center;
                width: 32px;
                height: 32px;
                border-radius: var(--lotus-border-radius-small);
                background: transparent;
                color: #fff;
                border: none;
                cursor: pointer;
                font-size: 16px;
            }

            .lotus-image-preview-tool-btn:hover {
                background: rgba(255, 255, 255, 0.2);
            }

            .lotus-image-preview-indicator {
                position: absolute;
                top: var(--lotus-spacing-loose);
                left: 50%;
                transform: translateX(-50%);
                padding: var(--lotus-spacing-super-tight) var(--lotus-spacing-tight);
                border-radius: var(--lotus-border-radius-small);
                background: rgba(0, 0, 0, 0.5);
                color: #fff;
                font-size: var(--lotus-font-label-size);
            }
        </style>
    </>
}
