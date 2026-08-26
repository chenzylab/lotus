import {
    sharedClasses, weightStyle, CopyableAction, resolveEllipsisConfig, resolveCopyableConfig, resolveLinkConfig,
    type TypographySharedProps, type TypographyWeight,
} from './shared.tsrx';

export type TitleHeading = 1 | 2 | 3 | 4 | 5 | 6;

export interface TypographyTitleProps extends TypographySharedProps {
    children?: any;
    heading?: TitleHeading;
    weight?: TypographyWeight;
    'aria-label'?: string;
}

export function TypographyTitle(&{
    children,
    heading = 1,
    type = 'primary',
    weight,
    disabled = false,
    mark = false,
    delete: strikethrough = false,
    underline = false,
    link,
    icon,
    copyable,
    ellipsis,
    style,
    class: className,
    'aria-label': ariaLabel,
}: TypographyTitleProps) @{
    const linkConfig = resolveLinkConfig(link);
    const copyableConfig = resolveCopyableConfig(copyable);
    const isPlainText = typeof children === 'string';
    const ellipsisConfig = isPlainText ? resolveEllipsisConfig(ellipsis) : null;

    const classes = sharedClasses(
        { type, disabled, mark, delete: strikethrough, underline, link, class: className },
        [
            `lotus-typography-title-h${heading}`,
            ellipsisConfig ? 'lotus-typography-ellipsis-line' : '',
        ],
    );

    const mergedStyle = { ...weightStyle(weight), ...style };

    <>
        @if (heading === 1) {
            <h1 class={classes} style={mergedStyle} aria-label={ariaLabel}>
                @if (icon) { <span class="lotus-typography-icon">{icon}</span> }
                <span>{children}</span>
                @if (copyableConfig) { <CopyableAction config={copyableConfig} textContent={isPlainText ? children : ''} /> }
            </h1>
        } @else if (heading === 2) {
            <h2 class={classes} style={mergedStyle} aria-label={ariaLabel}>
                @if (icon) { <span class="lotus-typography-icon">{icon}</span> }
                <span>{children}</span>
                @if (copyableConfig) { <CopyableAction config={copyableConfig} textContent={isPlainText ? children : ''} /> }
            </h2>
        } @else if (heading === 3) {
            <h3 class={classes} style={mergedStyle} aria-label={ariaLabel}>
                @if (icon) { <span class="lotus-typography-icon">{icon}</span> }
                <span>{children}</span>
                @if (copyableConfig) { <CopyableAction config={copyableConfig} textContent={isPlainText ? children : ''} /> }
            </h3>
        } @else if (heading === 4) {
            <h4 class={classes} style={mergedStyle} aria-label={ariaLabel}>
                @if (icon) { <span class="lotus-typography-icon">{icon}</span> }
                <span>{children}</span>
                @if (copyableConfig) { <CopyableAction config={copyableConfig} textContent={isPlainText ? children : ''} /> }
            </h4>
        } @else if (heading === 5) {
            <h5 class={classes} style={mergedStyle} aria-label={ariaLabel}>
                @if (icon) { <span class="lotus-typography-icon">{icon}</span> }
                <span>{children}</span>
                @if (copyableConfig) { <CopyableAction config={copyableConfig} textContent={isPlainText ? children : ''} /> }
            </h5>
        } @else {
            <h6 class={classes} style={mergedStyle} aria-label={ariaLabel}>
                @if (icon) { <span class="lotus-typography-icon">{icon}</span> }
                <span>{children}</span>
                @if (copyableConfig) { <CopyableAction config={copyableConfig} textContent={isPlainText ? children : ''} /> }
            </h6>
        }

        <style>
            .lotus-typography {
                font-family: var(--lotus-font-family);
                color: var(--lotus-color-text-0);
            }

            .lotus-typography-primary { color: var(--lotus-color-text-0); }
            .lotus-typography-secondary { color: var(--lotus-color-text-1); }
            .lotus-typography-tertiary { color: var(--lotus-color-text-2); }
            .lotus-typography-quaternary { color: var(--lotus-color-text-3); }
            .lotus-typography-warning { color: var(--lotus-color-warning); }
            .lotus-typography-danger { color: var(--lotus-color-danger); }
            .lotus-typography-success { color: var(--lotus-color-success); }

            .lotus-typography-disabled {
                color: var(--lotus-color-disabled-text);
                cursor: not-allowed;
            }

            .lotus-typography-mark {
                background: var(--lotus-color-highlight-bg);
                color: var(--lotus-color-highlight);
            }

            .lotus-typography-delete { text-decoration: line-through; }
            .lotus-typography-underline { text-decoration: underline; }

            .lotus-typography-link {
                color: var(--lotus-color-link);
                text-decoration: none;
                cursor: pointer;
            }
            .lotus-typography-link:hover { color: var(--lotus-color-link-hover); text-decoration: underline; }
            .lotus-typography-link:active { color: var(--lotus-color-link-active); }

            .lotus-typography-ellipsis-line {
                overflow: hidden;
                text-overflow: ellipsis;
                white-space: nowrap;
                max-width: 100%;
            }

            .lotus-typography-icon {
                display: inline-flex;
                align-items: center;
                margin-inline-end: 6px;
            }

            .lotus-typography-copy {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                border: none;
                background: transparent;
                padding: 0;
                margin-inline-start: 6px;
                color: var(--lotus-color-text-2);
                cursor: pointer;
                vertical-align: middle;
            }
            .lotus-typography-copy:hover { color: var(--lotus-color-text-0); }

            .lotus-typography-title-h1 { font-size: var(--lotus-font-h1-size); line-height: var(--lotus-font-h1-line-height); font-weight: var(--lotus-font-h1-weight); margin: 0; }
            .lotus-typography-title-h2 { font-size: var(--lotus-font-h2-size); line-height: var(--lotus-font-h2-line-height); font-weight: var(--lotus-font-h2-weight); margin: 0; }
            .lotus-typography-title-h3 { font-size: var(--lotus-font-h3-size); line-height: var(--lotus-font-h3-line-height); font-weight: var(--lotus-font-h3-weight); margin: 0; }
            .lotus-typography-title-h4 { font-size: var(--lotus-font-h4-size); line-height: var(--lotus-font-h4-line-height); font-weight: var(--lotus-font-h4-weight); margin: 0; }
            .lotus-typography-title-h5 { font-size: var(--lotus-font-h5-size); line-height: var(--lotus-font-h5-line-height); font-weight: var(--lotus-font-h5-weight); margin: 0; }
            .lotus-typography-title-h6 { font-size: var(--lotus-font-h6-size); line-height: var(--lotus-font-h6-line-height); font-weight: var(--lotus-font-h6-weight); margin: 0; }
        </style>
    </>
}
