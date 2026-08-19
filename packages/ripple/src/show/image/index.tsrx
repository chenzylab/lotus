import { track, effect, untrack } from 'ripple';
import { ImageFoundation, type ImageState } from '@lotus/foundation/show/image';
import { SkeletonImage } from '../../feedback/skeleton/index.tsrx';
import { IconUploadError } from '@lotus/icons';
import { Preview } from './preview.tsrx';
import { ImagePreviewGroupContext } from './image-preview-context.js';

export interface ImageProps {
    src?: string;
    alt?: string;
    width?: string | number;
    height?: string | number;
    fallback?: string | any;
    placeholder?: any;
    preview?: boolean;
    previewSrc?: string;
    onLoad?: (event: Event) => void;
    onError?: (event: Event) => void;
    onClick?: (event: MouseEvent) => void;
    imgClass?: string;
    imgStyle?: Record<string, any>;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

export function Image(&{
    src,
    alt,
    width,
    height,
    fallback,
    placeholder,
    preview = true,
    previewSrc,
    onLoad,
    onError,
    onClick,
    imgClass,
    imgStyle,
    style,
    class: className,
    'aria-label': ariaLabel,
}: ImageProps) @{
    let &[state] = track<ImageState>({ loadStatus: 'loading' });
    let &[previewVisible] = track<boolean>(false);

    const foundation = new ImageFoundation({
        getState: () => untrack(() => state),
        setState: (patch) => { state = { ...untrack(() => state), ...patch }; },
    });

    const contextTracked = ImagePreviewGroupContext.get();
    let &[groupIndex] = track<number | null>(null);

    effect(() => {
        if (!contextTracked) return;
        const index = contextTracked.value.register(src ?? '');
        untrack(() => { groupIndex = index; });
    });

    effect(() => {
        void src;
        untrack(() => foundation.resetForNewSrc());
    });

    function handleLoad(event: Event) {
        foundation.handleLoad();
        onLoad?.(event);
    }

    function handleError(event: Event) {
        foundation.handleError();
        onError?.(event);
    }

    function handleClick(event: MouseEvent) {
        onClick?.(event);
        if (!preview) return;
        const ctx = untrack(() => contextTracked);
        if (ctx) {
            ctx.value.openAt(untrack(() => groupIndex) ?? 0);
            return;
        }
        previewVisible = true;
    }

    let &[classes] = track<string>(() =>
        ['lotus-image', preview ? 'lotus-image-can-preview' : '', className ?? ''].filter(Boolean).join(' '),
    );

    let &[wrapperStyle] = track<Record<string, any>>(() => ({ ...style, width, height }));
    let &[isFallbackString] = track<boolean>(() => typeof fallback === 'string');

    <>
        <div class={classes} style={wrapperStyle} aria-label={ariaLabel} onClick={handleClick}>
            @if (state.loadStatus === 'loading') {
                <div class="lotus-image-overlay">
                    @if (placeholder !== undefined) {
                        <>{placeholder}</>
                    }
                    @if (placeholder === undefined) {
                        <SkeletonImage style={{ width: '100%', height: '100%' }} />
                    }
                </div>
            }
            @if (state.loadStatus === 'error' && fallback !== undefined) {
                <div class="lotus-image-overlay">
                    @if (isFallbackString) {
                        <img class="lotus-image-img" src={fallback} alt={alt} />
                    }
                    @if (!isFallbackString) {
                        <>{fallback}</>
                    }
                </div>
            }
            @if (state.loadStatus === 'error' && fallback === undefined) {
                <div class="lotus-image-overlay lotus-image-error">
                    <IconUploadError />
                </div>
            }
            <img
                class={['lotus-image-img', state.loadStatus === 'success' ? '' : 'lotus-image-img-hidden', imgClass ?? ''].filter(Boolean).join(' ')}
                src={src}
                alt={alt}
                style={imgStyle}
                onLoad={handleLoad}
                onError={handleError}
            />
        </div>

        @if (!contextTracked) {
            <Preview
                srcList={[previewSrc ?? src ?? '']}
                currentIndex={0}
                visible={previewVisible}
                onClose={() => { previewVisible = false; }}
            />
        }

        <style>
            .lotus-image {
                position: relative;
                display: inline-block;
                overflow: hidden;
                background: var(--lotus-color-fill-0);
                border-radius: var(--lotus-border-radius-small);
            }

            .lotus-image-can-preview {
                cursor: pointer;
            }

            .lotus-image-img {
                display: block;
                width: 100%;
                height: 100%;
                object-fit: cover;
            }

            .lotus-image-img-hidden {
                position: absolute;
                inset: 0;
                opacity: 0;
                pointer-events: none;
            }

            .lotus-image-overlay {
                width: 100%;
                height: 100%;
                min-width: 48px;
                min-height: 48px;
            }

            .lotus-image-error {
                display: flex;
                align-items: center;
                justify-content: center;
                color: var(--lotus-color-text-2);
                font-size: 24px;
            }
        </style>
    </>
}
