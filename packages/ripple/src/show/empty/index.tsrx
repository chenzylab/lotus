import { track, effect, untrack } from 'ripple';
import { TypographyTitle } from '../../basic/typography/title.tsrx';

export type EmptyLayout = 'vertical' | 'horizontal';

export interface EmptyProps {
    image?: any;
    /** 深色模式下替换 image 展示的图片，仅在 `document.documentElement`
     * 的 `data-theme` 属性变化为 `"dark"` 时切换（对齐 Semi 用
     * MutationObserver 监听 body `theme-mode` 属性的机制，lotus 的等价
     * 主题标记写在 html 根元素而不是 body，见 ConfigProvider 说明）。 */
    darkModeImage?: any;
    title?: any;
    description?: any;
    layout?: EmptyLayout;
    imageStyle?: Record<string, any>;
    children?: any;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

export function Empty(&{
    image,
    darkModeImage,
    title,
    description,
    layout = 'vertical',
    imageStyle,
    children,
    style,
    class: className,
    'aria-label': ariaLabel,
}: EmptyProps) @{
    const classes = ['lotus-empty', `lotus-empty-${layout}`, className ?? ''].filter(Boolean).join(' ');
    const isTitleString = typeof title === 'string';
    const headingLevel = image !== undefined ? 4 : 6;
    const hasChildren = children !== undefined && children !== null;

    let &[isDark] = track<boolean>(() => untrack(() => document.documentElement.getAttribute('data-theme') === 'dark'));

    effect(() => {
        if (darkModeImage === undefined || typeof MutationObserver === 'undefined') return;
        const observer = new MutationObserver(() => {
            const next = document.documentElement.getAttribute('data-theme') === 'dark';
            untrack(() => { if (next !== isDark) isDark = next; });
        });
        observer.observe(document.documentElement, { attributes: true, attributeFilter: ['data-theme'] });
        return () => observer.disconnect();
    });

    let &[displayImage] = track<any>(() => (isDark && darkModeImage !== undefined) ? darkModeImage : image);

    <>
        <div class={classes} style={style} aria-label={ariaLabel}>
            <div class="lotus-empty-image" style={imageStyle}>
                {displayImage}
            </div>
            <div class="lotus-empty-content">
                @if (title !== undefined && isTitleString) {
                    <TypographyTitle heading={headingLevel} weight={image !== undefined ? 'default' : 'regular'}>{title}</TypographyTitle>
                }
                @if (title !== undefined && !isTitleString) {
                    <>{title}</>
                }
                @if (description !== undefined) {
                    <div class="lotus-empty-description">{description}</div>
                }
            </div>
            @if (hasChildren) {
                <div class="lotus-empty-footer">{children}</div>
            }
        </div>

        <style>
            .lotus-empty {
                display: flex;
                box-sizing: border-box;
            }

            .lotus-empty-vertical {
                flex-direction: column;
                align-items: center;
                text-align: center;
            }

            .lotus-empty-horizontal {
                flex-direction: row;
                align-items: center;
            }

            .lotus-empty-image {
                flex-shrink: 0;
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .lotus-empty-vertical .lotus-empty-content {
                margin-top: var(--lotus-spacing-loose);
            }

            .lotus-empty-horizontal .lotus-empty-content {
                margin-inline-start: var(--lotus-spacing-extra-loose);
            }

            .lotus-empty-description {
                margin-top: var(--lotus-spacing-super-tight);
                color: var(--lotus-color-text-2);
                font-size: var(--lotus-font-body-size);
            }

            .lotus-empty-footer {
                margin-top: var(--lotus-spacing-loose);
            }
        </style>
    </>
}
