import { Skeleton, SkeletonTitle, SkeletonParagraph } from '../../feedback/skeleton/index.tsrx';
import { TypographyTitle } from '../../basic/typography/title.tsrx';
import { Space } from '../../basic/space/index.tsrx';

export type CardShadows = 'hover' | 'always';

export interface CardProps {
    children?: any;
    title?: any;
    header?: any;
    headerExtraContent?: any;
    headerLine?: boolean;
    headerStyle?: Record<string, any>;
    cover?: any;
    bodyStyle?: Record<string, any>;
    footer?: any;
    footerLine?: boolean;
    footerStyle?: Record<string, any>;
    actions?: any[];
    bordered?: boolean;
    shadows?: CardShadows;
    loading?: boolean;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

export function Card(&{
    children,
    title,
    header,
    headerExtraContent,
    headerLine = true,
    headerStyle,
    cover,
    bodyStyle,
    footer,
    footerLine = false,
    footerStyle,
    actions,
    bordered = true,
    shadows,
    loading = false,
    style,
    class: className,
    'aria-label': ariaLabel,
}: CardProps) @{
    const classes = [
        'lotus-card',
        bordered ? 'lotus-card-bordered' : '',
        shadows ? `lotus-card-shadows-${shadows}` : '',
        className ?? '',
    ].filter(Boolean).join(' ');

    const hasHeader = header !== undefined || title !== undefined || headerExtraContent !== undefined;
    const isTitleString = typeof title === 'string';
    const hasActions = Array.isArray(actions) && actions.length > 0;

    <>
        <div class={classes} style={style} aria-label={ariaLabel} aria-busy={loading}>
            @if (hasHeader && header !== undefined) {
                <div class={['lotus-card-header', headerLine ? 'lotus-card-header-line' : ''].filter(Boolean).join(' ')} style={headerStyle}>
                    {header}
                </div>
            }
            @if (hasHeader && header === undefined) {
                <div class={['lotus-card-header', headerLine ? 'lotus-card-header-line' : ''].filter(Boolean).join(' ')} style={headerStyle}>
                    <div class="lotus-card-header-main">
                        @if (isTitleString) {
                            <TypographyTitle heading={6} ellipsis={{ showTooltip: true }}>{title}</TypographyTitle>
                        }
                        @if (!isTitleString) {
                            <>{title}</>
                        }
                    </div>
                    @if (headerExtraContent !== undefined) {
                        <div class="lotus-card-header-extra">{headerExtraContent}</div>
                    }
                </div>
            }

            @if (cover !== undefined) {
                <div class="lotus-card-cover">{cover}</div>
            }

            <div class="lotus-card-body" style={bodyStyle}>
                <Skeleton loading={loading} active placeholder={
                    <>
                        <SkeletonTitle />
                        <SkeletonParagraph rows={3} />
                    </>
                }>
                    {children}
                </Skeleton>
            </div>

            @if (hasActions) {
                <div class="lotus-card-actions">
                    <Space spacing={12}>{actions}</Space>
                </div>
            }

            @if (footer !== undefined) {
                <div class={['lotus-card-footer', footerLine ? 'lotus-card-footer-line' : ''].filter(Boolean).join(' ')} style={footerStyle}>
                    {footer}
                </div>
            }
        </div>

        <style>
            .lotus-card {
                display: flex;
                flex-direction: column;
                background: var(--lotus-color-bg-1);
                border-radius: var(--lotus-border-radius-medium);
                overflow: hidden;
            }

            .lotus-card-bordered {
                border: 1px solid var(--lotus-color-border);
            }

            .lotus-card-shadows-hover {
                cursor: pointer;
                transition: box-shadow 0.3s ease;
            }

            .lotus-card-shadows-hover:hover {
                box-shadow: var(--lotus-shadow-elevated);
            }

            .lotus-card-shadows-always {
                cursor: pointer;
                box-shadow: var(--lotus-shadow-elevated);
            }

            .lotus-card-header {
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: var(--lotus-spacing-tight);
                padding: var(--lotus-spacing-base) var(--lotus-spacing-base-loose);
            }

            .lotus-card-header-line {
                border-bottom: 1px solid var(--lotus-color-border);
            }

            .lotus-card-header-main {
                flex: 1;
                min-width: 0;
            }

            .lotus-card-header-extra {
                flex-shrink: 0;
            }

            .lotus-card-cover > * {
                display: block;
                width: 100%;
            }

            .lotus-card-body {
                flex: 1;
                padding: var(--lotus-spacing-base-loose);
            }

            .lotus-card-actions {
                padding: var(--lotus-spacing-tight) var(--lotus-spacing-base-loose);
                border-top: 1px solid var(--lotus-color-border);
            }

            .lotus-card-footer {
                padding: var(--lotus-spacing-base) var(--lotus-spacing-base-loose);
            }

            .lotus-card-footer-line {
                border-top: 1px solid var(--lotus-color-border);
            }
        </style>
    </>
}

export interface CardMetaProps {
    avatar?: any;
    title?: any;
    description?: any;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

export function CardMeta(&{ avatar, title, description, style, class: className, 'aria-label': ariaLabel }: CardMetaProps) @{
    const classes = ['lotus-card-meta', className ?? ''].filter(Boolean).join(' ');

    <>
        <div class={classes} style={style} aria-label={ariaLabel}>
            @if (avatar !== undefined) {
                <div class="lotus-card-meta-avatar">{avatar}</div>
            }
            <div class="lotus-card-meta-main">
                @if (title !== undefined) {
                    <div class="lotus-card-meta-title">{title}</div>
                }
                @if (description !== undefined) {
                    <div class="lotus-card-meta-description">{description}</div>
                }
            </div>
        </div>

        <style>
            .lotus-card-meta {
                display: flex;
                align-items: flex-start;
                gap: var(--lotus-spacing-tight);
            }

            .lotus-card-meta-avatar {
                flex-shrink: 0;
            }

            .lotus-card-meta-main {
                flex: 1;
                min-width: 0;
            }

            .lotus-card-meta-title {
                font-size: var(--lotus-font-body-size);
                font-weight: 600;
                color: var(--lotus-color-text-0);
            }

            .lotus-card-meta-description {
                margin-top: var(--lotus-spacing-super-tight);
                font-size: var(--lotus-font-body-size);
                color: var(--lotus-color-text-2);
            }
        </style>
    </>
}

export interface CardGroupProps {
    children?: any;
    spacing?: number | number[];
    type?: 'grid';
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

export function CardGroup(&{ children, spacing = 16, type, style, class: className, 'aria-label': ariaLabel }: CardGroupProps) @{
    const isGrid = type === 'grid';
    const [horizontalSpacing, verticalSpacing] = Array.isArray(spacing) ? spacing : [spacing, spacing];
    const classes = ['lotus-card-group', isGrid ? 'lotus-card-group-grid' : '', className ?? ''].filter(Boolean).join(' ');
    const gapValue = isGrid ? undefined : `${verticalSpacing}px ${horizontalSpacing}px`;
    const mergedStyle: Record<string, any> = { ...style };
    if (gapValue !== undefined) mergedStyle.gap = gapValue;

    <>
        <div class={classes} style={mergedStyle} aria-label={ariaLabel}>
            {children}
        </div>

        <style>
            .lotus-card-group {
                display: flex;
                flex-wrap: wrap;
            }

            .lotus-card-group-grid {
                gap: 0;
            }

            .lotus-card-group-grid > :global(.lotus-card) {
                border-radius: 0;
                margin: -1px 0 0 -1px;
            }
        </style>
    </>
}
