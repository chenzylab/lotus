import { track, effect, untrack } from 'ripple';
import { EllipsisFoundation } from '@lotus/foundation/basic/typography';
import { Tooltip } from '../../show/tooltip/index.tsrx';
import { measureEllipsisText } from './measure';
import {
    sharedClasses, weightStyle, CopyableAction, resolveEllipsisConfig, resolveCopyableConfig, resolveLinkConfig,
    type TypographySharedProps, type TypographySize, type TypographyWeight,
} from './shared.tsrx';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export interface TypographyTextProps extends TypographySharedProps {
    children?: any;
    size?: TypographySize;
    weight?: TypographyWeight;
    onClick?: (event: MouseEvent) => void;
    'aria-label'?: string;
}

/**
 * ellipsis 只在 children 是纯 string 时生效（与 Semi 官方文档 Notice 一致：
 * "仅支持纯文本截断，不支持 reactNode"，不是 Ripple 限制导致的额外妥协）。
 * 调用方需要用 `children={'...'}` 显式 prop 写法而非 `<Text>...</Text>` 标签子节点写法——
 * Ripple 编译器对 JSX 标签子节点无条件包装成 TSRXElement，只有显式 prop 才原样透传字符串，
 * 详见 specs/cross-cutting/foundation-adapter-pattern.md 踩坑记录。
 */
export function TypographyText(&{
    children,
    type = 'primary',
    size = 'normal',
    weight,
    disabled = false,
    mark = false,
    code = false,
    delete: strikethrough = false,
    underline = false,
    strong = false,
    link,
    icon,
    copyable,
    ellipsis,
    onClick,
    style,
    class: className,
    'aria-label': ariaLabel,
}: TypographyTextProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    const linkConfig = resolveLinkConfig(link);
    const copyableConfig = resolveCopyableConfig(copyable);
    const isPlainText = typeof children === 'string';
    const ellipsisConfig = isPlainText ? resolveEllipsisConfig(ellipsis) : null;

    let &[expanded] = track<boolean>(false);
    let &[containerNode] = track<HTMLElement | null>(null);
    let &[expandNode] = track<HTMLElement | null>(null);
    let &[copyNode] = track<HTMLElement | null>(null);
    let &[measuredText] = track<string>(isPlainText ? children : '');

    const needsJsTruncate = ellipsisConfig
        ? EllipsisFoundation.needsJsTruncate(ellipsisConfig, !!copyableConfig)
        : false;

    // 精确 JS 截断：挂载后在隐藏影子容器里用二分查找测量最大可容纳文本（含展开/复制按钮占位），
    // 移植自 Semi packages/semi-ui/typography/util.tsx 的 getRenderText 算法。
    effect(() => {
        if (!ellipsisConfig || !isPlainText || !needsJsTruncate) return;
        const node = untrack(() => containerNode);
        if (!node) return;
        if (untrack(() => expanded)) {
            measuredText = children;
            return;
        }
        const rows = ellipsisConfig.rows ?? 1;
        const result = measureEllipsisText(
            node,
            rows,
            children,
            { expand: untrack(() => expandNode), copy: untrack(() => copyNode) },
            ellipsisConfig.suffix ?? '',
            ellipsisConfig.pos ?? 'end',
        );
        measuredText = result;
    });

    const classes = sharedClasses(
        { type, disabled, mark, delete: strikethrough, underline, strong, link, class: className },
        [
            `lotus-typography-size-${size}`,
            ellipsisConfig && !needsJsTruncate && !ellipsisConfig.rows ? 'lotus-typography-ellipsis-line' : '',
            ellipsisConfig && !needsJsTruncate && ellipsisConfig.rows && ellipsisConfig.rows > 1 ? 'lotus-typography-ellipsis-multiline' : '',
            code ? 'lotus-typography-code' : '',
        ],
    );

    const rowsStyle: Record<string, string | number> = (!needsJsTruncate && ellipsisConfig?.rows && ellipsisConfig.rows > 1)
        ? { WebkitLineClamp: String(ellipsisConfig.rows) }
        : {};

    const mergedStyle = { ...weightStyle(weight), ...rowsStyle, ...style };

    <>
        @if (linkConfig) {
            <a class={classes} style={mergedStyle} aria-label={ariaLabel} {...linkConfig}>
                @if (icon) {
                    <span class="lotus-typography-icon">{icon}</span>
                }
                <span>{children}</span>
            </a>
        } @else if (ellipsisConfig?.showTooltip && !expanded) {
            <Tooltip content={children} block>
                <span
                    class={classes}
                    style={mergedStyle}
                    aria-label={ariaLabel}
                    onClick={onClick}
                    ref={(node: HTMLElement) => { containerNode = node; }}
                >
                    @if (icon) {
                        <span class="lotus-typography-icon">{icon}</span>
                    }
                    <span>{needsJsTruncate ? measuredText : children}</span>
                    @if (ellipsisConfig?.expandable || ellipsisConfig?.collapsible) {
                        <button
                            type="button"
                            class="lotus-typography-expand-toggle"
                            ref={(node: HTMLElement) => { expandNode = node; }}
                            onClick={(event: MouseEvent) => {
                                event.stopPropagation();
                                expanded = !expanded;
                                ellipsisConfig?.onExpand?.(expanded, event);
                            }}
                        >
                            {expanded ? (ellipsisConfig.collapseText ?? locale.Typography.collapseText) : (ellipsisConfig.expandText ?? locale.Typography.expandText)}
                        </button>
                    }
                    @if (copyableConfig) {
                        <CopyableAction config={copyableConfig} textContent={isPlainText ? children : ''} nodeRef={(node: HTMLElement) => { copyNode = node; }} />
                    }
                </span>
            </Tooltip>
        } @else {
            <span
                class={classes}
                style={mergedStyle}
                aria-label={ariaLabel}
                onClick={onClick}
                ref={(node: HTMLElement) => { containerNode = node; }}
            >
                @if (icon) {
                    <span class="lotus-typography-icon">{icon}</span>
                }
                <span>{needsJsTruncate ? measuredText : children}</span>
                @if (ellipsisConfig?.expandable || ellipsisConfig?.collapsible) {
                    <button
                        type="button"
                        class="lotus-typography-expand-toggle"
                        ref={(node: HTMLElement) => { expandNode = node; }}
                        onClick={(event: MouseEvent) => {
                            event.stopPropagation();
                            expanded = !expanded;
                            ellipsisConfig?.onExpand?.(expanded, event);
                        }}
                    >
                        {expanded ? (ellipsisConfig.collapseText ?? locale.Typography.collapseText) : (ellipsisConfig.expandText ?? locale.Typography.expandText)}
                    </button>
                }
                @if (copyableConfig) {
                    <CopyableAction config={copyableConfig} textContent={isPlainText ? children : ''} nodeRef={(node: HTMLElement) => { copyNode = node; }} />
                }
            </span>
        }

        <style>
            .lotus-typography {
                font-family: var(--lotus-font-family);
                color: var(--lotus-color-text-0);
                line-height: var(--lotus-font-body-line-height);
            }

            .lotus-typography-size-normal { font-size: var(--lotus-font-body-size); line-height: var(--lotus-font-body-line-height); }
            .lotus-typography-size-small { font-size: var(--lotus-font-label-size); line-height: var(--lotus-font-label-line-height); }
            .lotus-typography-size-inherit { font-size: inherit; line-height: inherit; }

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

            .lotus-typography-code {
                font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
                background: var(--lotus-color-fill-0);
                border: 1px solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-small);
                padding: 1px 6px;
                font-size: 0.9em;
            }

            .lotus-typography-delete { text-decoration: line-through; }
            .lotus-typography-underline { text-decoration: underline; }
            .lotus-typography-strong { font-weight: var(--lotus-font-weight-semibold); }

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
                display: block;
                width: 100%;
                vertical-align: bottom;
            }

            .lotus-typography-ellipsis-multiline {
                display: -webkit-box;
                -webkit-box-orient: vertical;
                overflow: hidden;
            }

            .lotus-typography-icon {
                display: inline-flex;
                align-items: center;
                margin-right: 6px;
            }

            .lotus-typography-copy {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                border: none;
                background: transparent;
                padding: 0;
                margin-left: 6px;
                color: var(--lotus-color-text-2);
                cursor: pointer;
                vertical-align: middle;
            }
            .lotus-typography-copy:hover { color: var(--lotus-color-text-0); }

            .lotus-typography-expand-toggle {
                display: inline;
                border: none;
                background: transparent;
                padding: 0;
                margin-left: 4px;
                color: var(--lotus-color-link);
                cursor: pointer;
                font-size: inherit;
            }
            .lotus-typography-expand-toggle:hover { color: var(--lotus-color-link-hover); }
        </style>
    </>
}
