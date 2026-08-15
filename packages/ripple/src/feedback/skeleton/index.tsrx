import { IconImageStroked } from '@lotus/icons';

export type SkeletonAvatarSize = 'extra-extra-small' | 'extra-small' | 'small' | 'medium' | 'large' | 'extra-large';
export type SkeletonAvatarShape = 'circle' | 'square';

export interface SkeletonProps {
    children?: any;
    active?: boolean;
    loading?: boolean;
    placeholder?: any;
    style?: Record<string, any>;
    class?: string;
}

export function Skeleton({
    children,
    active = false,
    loading = true,
    placeholder,
    style,
    class: className,
}: SkeletonProps) @{
    const classes = ['lotus-skeleton', active ? 'lotus-skeleton-active' : '', className ?? ''].filter(Boolean).join(' ');

    <>
        @if (loading) {
            <div class={classes} style={style}>{placeholder}</div>
        } @else {
            <>{children}</>
        }

        <style>
            .lotus-skeleton {
                display: contents;
            }
        </style>
    </>
}


export interface SkeletonAvatarProps {
    size?: SkeletonAvatarSize;
    shape?: SkeletonAvatarShape;
    style?: Record<string, any>;
    class?: string;
}

export function SkeletonAvatar({ size = 'medium', shape = 'circle', style, class: className }: SkeletonAvatarProps) @{
    const classes = [
        'lotus-skeleton-element',
        'lotus-skeleton-avatar',
        `lotus-skeleton-avatar-${size}`,
        `lotus-skeleton-avatar-${shape}`,
        className ?? '',
    ].filter(Boolean).join(' ');

    <>
        <div class={classes} style={style} />

        <style>
            .lotus-skeleton-element {
                background: var(--lotus-color-fill-1);
            }

            .lotus-skeleton-active .lotus-skeleton-element {
                background: linear-gradient(
                    90deg,
                    var(--lotus-color-fill-1) 25%,
                    var(--lotus-color-fill-2) 37%,
                    var(--lotus-color-fill-1) 63%
                );
                background-size: 400% 100%;
                animation: lotus-skeleton-loading 1.4s ease infinite;
            }

            @keyframes lotus-skeleton-loading {
                0% {
                    background-position: 100% 50%;
                }

                to {
                    background-position: 0 50%;
                }
            }

            .lotus-skeleton-avatar {
                display: inline-block;
            }

            .lotus-skeleton-avatar-circle {
                border-radius: var(--lotus-border-radius-circle);
            }

            .lotus-skeleton-avatar-square {
                border-radius: var(--lotus-border-radius-small);
            }

            .lotus-skeleton-avatar-extra-extra-small {
                width: 20px;
                height: 20px;
            }

            .lotus-skeleton-avatar-extra-small {
                width: 24px;
                height: 24px;
            }

            .lotus-skeleton-avatar-small {
                width: 32px;
                height: 32px;
            }

            .lotus-skeleton-avatar-medium {
                width: 48px;
                height: 48px;
            }

            .lotus-skeleton-avatar-large {
                width: 72px;
                height: 72px;
            }

            .lotus-skeleton-avatar-extra-large {
                width: 128px;
                height: 128px;
            }
        </style>
    </>
}

export interface SkeletonImageProps {
    style?: Record<string, any>;
    class?: string;
}

export function SkeletonImage({ style, class: className }: SkeletonImageProps) @{
    const classes = ['lotus-skeleton-element', 'lotus-skeleton-image', className ?? ''].filter(Boolean).join(' ');

    <>
        <div class={classes} style={style}>
            <IconImageStroked style={{ fontSize: '24px' }} />
        </div>

        <style>
            .lotus-skeleton-element {
                background: var(--lotus-color-fill-1);
            }

            .lotus-skeleton-active .lotus-skeleton-element {
                background: linear-gradient(
                    90deg,
                    var(--lotus-color-fill-1) 25%,
                    var(--lotus-color-fill-2) 37%,
                    var(--lotus-color-fill-1) 63%
                );
                background-size: 400% 100%;
                animation: lotus-skeleton-loading 1.4s ease infinite;
            }

            @keyframes lotus-skeleton-loading {
                0% {
                    background-position: 100% 50%;
                }

                to {
                    background-position: 0 50%;
                }
            }

            .lotus-skeleton-image {
                width: 100%;
                height: 100%;
                min-width: 48px;
                min-height: 48px;
                display: flex;
                align-items: center;
                justify-content: center;
                color: var(--lotus-color-fill-2);
                border-radius: var(--lotus-border-radius-small);
            }
        </style>
    </>
}

export interface SkeletonTitleProps {
    style?: Record<string, any>;
    class?: string;
}

export function SkeletonTitle({ style, class: className }: SkeletonTitleProps) @{
    const classes = ['lotus-skeleton-element', 'lotus-skeleton-title', className ?? ''].filter(Boolean).join(' ');

    <>
        <div class={classes} style={style} />

        <style>
            .lotus-skeleton-element {
                background: var(--lotus-color-fill-1);
            }

            .lotus-skeleton-active .lotus-skeleton-element {
                background: linear-gradient(
                    90deg,
                    var(--lotus-color-fill-1) 25%,
                    var(--lotus-color-fill-2) 37%,
                    var(--lotus-color-fill-1) 63%
                );
                background-size: 400% 100%;
                animation: lotus-skeleton-loading 1.4s ease infinite;
            }

            @keyframes lotus-skeleton-loading {
                0% {
                    background-position: 100% 50%;
                }

                to {
                    background-position: 0 50%;
                }
            }

            .lotus-skeleton-title {
                width: 100%;
                height: 24px;
                border-radius: var(--lotus-border-radius-small);
            }
        </style>
    </>
}

export interface SkeletonButtonProps {
    style?: Record<string, any>;
    class?: string;
}

export function SkeletonButton({ style, class: className }: SkeletonButtonProps) @{
    const classes = ['lotus-skeleton-element', 'lotus-skeleton-button', className ?? ''].filter(Boolean).join(' ');

    <>
        <div class={classes} style={style} />

        <style>
            .lotus-skeleton-element {
                background: var(--lotus-color-fill-1);
            }

            .lotus-skeleton-active .lotus-skeleton-element {
                background: linear-gradient(
                    90deg,
                    var(--lotus-color-fill-1) 25%,
                    var(--lotus-color-fill-2) 37%,
                    var(--lotus-color-fill-1) 63%
                );
                background-size: 400% 100%;
                animation: lotus-skeleton-loading 1.4s ease infinite;
            }

            @keyframes lotus-skeleton-loading {
                0% {
                    background-position: 100% 50%;
                }

                to {
                    background-position: 0 50%;
                }
            }

            .lotus-skeleton-button {
                width: 115px;
                height: 32px;
                border-radius: var(--lotus-border-radius-small);
            }
        </style>
    </>
}

export interface SkeletonParagraphProps {
    rows?: number;
    style?: Record<string, any>;
    class?: string;
}

export function SkeletonParagraph({ rows = 4, style, class: className }: SkeletonParagraphProps) @{
    const classes = ['lotus-skeleton-paragraph', className ?? ''].filter(Boolean).join(' ');
    const rowIndexes = Array.from({ length: rows }, (_, i) => i);

    <>
        <div class={classes} style={style}>
            @for (const i of rowIndexes; index idx; key idx) {
                <div class={['lotus-skeleton-element', 'lotus-skeleton-paragraph-row', i === rows - 1 && rows > 1 ? 'lotus-skeleton-paragraph-row-last' : ''].filter(Boolean).join(' ')} />
            }
        </div>

        <style>
            .lotus-skeleton-element {
                background: var(--lotus-color-fill-1);
            }

            .lotus-skeleton-active .lotus-skeleton-element {
                background: linear-gradient(
                    90deg,
                    var(--lotus-color-fill-1) 25%,
                    var(--lotus-color-fill-2) 37%,
                    var(--lotus-color-fill-1) 63%
                );
                background-size: 400% 100%;
                animation: lotus-skeleton-loading 1.4s ease infinite;
            }

            @keyframes lotus-skeleton-loading {
                0% {
                    background-position: 100% 50%;
                }

                to {
                    background-position: 0 50%;
                }
            }

            .lotus-skeleton-paragraph-row {
                width: 100%;
                height: 16px;
                border-radius: var(--lotus-border-radius-small);
                margin-bottom: 10px;
            }

            .lotus-skeleton-paragraph-row:last-child {
                margin-bottom: 0;
            }

            .lotus-skeleton-paragraph-row-last {
                width: 61%;
            }
        </style>
    </>
}
