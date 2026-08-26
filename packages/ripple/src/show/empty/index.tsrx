import { TypographyTitle } from '../../basic/typography/title.tsrx';

export type EmptyLayout = 'vertical' | 'horizontal';

export interface EmptyProps {
    image?: any;
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

    <>
        <div class={classes} style={style} aria-label={ariaLabel}>
            <div class="lotus-empty-image" style={imageStyle}>
                {image}
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
