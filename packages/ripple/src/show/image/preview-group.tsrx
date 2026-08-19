import { track, untrack } from 'ripple';
import { Preview } from './preview.tsrx';
import { ImagePreviewGroupContext, type ImagePreviewContextValue } from './image-preview-context.js';

export interface ImagePreviewGroupProps {
    children?: any;
    src?: string[];
    visible?: boolean;
    defaultCurrentIndex?: number;
    currentIndex?: number;
    onVisibleChange?: (visible: boolean, index: number) => void;
    onIndexChange?: (index: number) => void;
    maskClosable?: boolean;
    closeOnEsc?: boolean;
    infinite?: boolean;
    zIndex?: number;
}

export function ImagePreviewGroup(&{
    children,
    src,
    visible: visibleProp,
    defaultCurrentIndex = 0,
    currentIndex: currentIndexProp,
    onVisibleChange,
    onIndexChange,
    maskClosable = true,
    closeOnEsc = true,
    infinite = true,
    zIndex = 1050,
}: ImagePreviewGroupProps) @{
    const isControlled = visibleProp !== undefined;
    let &[registeredSrcList] = track<string[]>([]);
    let &[isVisible] = track<boolean>(() => (isControlled ? !!visibleProp : false));
    let &[activeIndex] = track<number>(defaultCurrentIndex);

    let &[srcList] = track<string[]>(() => (src && src.length > 0 ? src : registeredSrcList));

    function register(itemSrc: string): number {
        const list = untrack(() => registeredSrcList);
        const existingIndex = list.indexOf(itemSrc);
        if (existingIndex !== -1) return existingIndex;
        registeredSrcList = [...list, itemSrc];
        return registeredSrcList.length - 1;
    }

    function openAt(index: number) {
        activeIndex = index;
        if (!isControlled) isVisible = true;
        onVisibleChange?.(true, index);
    }

    function handleClose() {
        if (!isControlled) isVisible = false;
        onVisibleChange?.(false, activeIndex);
    }

    function handleIndexChange(index: number) {
        activeIndex = index;
        onIndexChange?.(index);
    }

    let &[, contextTracked] = track<ImagePreviewContextValue>(() => ({ register, openAt }));
    ImagePreviewGroupContext.set(contextTracked);

    let &[resolvedCurrentIndex] = track<number>(() => currentIndexProp ?? activeIndex);

    <>
        <>{children}</>

        <Preview
            srcList={srcList}
            currentIndex={resolvedCurrentIndex}
            visible={isVisible}
            onClose={handleClose}
            onIndexChange={handleIndexChange}
            maskClosable={maskClosable}
            closeOnEsc={closeOnEsc}
            infinite={infinite}
            zIndex={zIndex}
        />
    </>
}
