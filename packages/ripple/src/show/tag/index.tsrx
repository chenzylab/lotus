import { track } from 'ripple';
import { IconClose } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';
import { Avatar } from '../avatar/index.tsrx';

export type TagColor =
    | 'amber' | 'blue' | 'cyan' | 'green' | 'grey' | 'indigo' | 'lightBlue' | 'lightGreen'
    | 'lime' | 'orange' | 'pink' | 'purple' | 'red' | 'teal' | 'violet' | 'yellow' | 'white';
export type TagType = 'ghost' | 'solid' | 'light';
export type TagSize = 'default' | 'small' | 'large';
export type TagShape = 'circle' | 'square';
export type TagAvatarShape = 'circle' | 'square';

export interface TagProps {
    children?: any;
    /** 标识该标签的 key，`onClose` 回调透传，多标签场景（如 TagGroup）区分是哪一个被关闭。 */
    tagKey?: string | number;
    size?: TagSize;
    color?: TagColor;
    type?: TagType;
    /** 标签外观形状：`square`（默认，方角）或 `circle`（胶囊形，完全圆角）。 */
    shape?: TagShape;
    closable?: boolean;
    visible?: boolean;
    /** AI 多彩风格（对齐 Semi `colorful`），生效时忽略 `color` 语义色，改用 AI 渐变色系。 */
    colorful?: boolean;
    /** 配合 `colorful` 使用：是否用渐变色而非纯色（对齐 Semi `gradient`），单独设置无效果。 */
    gradient?: boolean;
    /** 标签内嵌头像图片地址，与 `prefixIcon` 互斥的独立能力。 */
    avatarSrc?: string;
    /** 内嵌头像的形状。 */
    avatarShape?: TagAvatarShape;
    onClose?: (children: any, event: MouseEvent | KeyboardEvent, tagKey: string | number | undefined) => void;
    onClick?: (event: MouseEvent) => void;
    onKeyDown?: (event: KeyboardEvent) => void;
    onMouseEnter?: () => void;
    prefixIcon?: any;
    suffixIcon?: any;
    /** 内部使用：TagInput 场景需要用 -1 关闭 Tag 自身的 Tab 序，改由外层管理焦点。 */
    tabIndex?: number;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

export function Tag(&{
    children,
    tagKey,
    size = 'default',
    color = 'grey',
    type = 'light',
    shape = 'square',
    closable = false,
    visible: visibleProp,
    colorful = false,
    gradient = false,
    avatarSrc,
    avatarShape = 'square',
    onClose,
    onClick,
    onKeyDown,
    onMouseEnter,
    prefixIcon,
    suffixIcon,
    tabIndex,
    style,
    class: className,
    'aria-label': ariaLabel,
}: TagProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    const isControlledVisible = visibleProp !== undefined;
    let &[internalVisible] = track<boolean>(true);
    let &[visible] = track<boolean>(() => (isControlledVisible ? !!visibleProp : internalVisible));

    let &[classes] = track<string>(() =>
        [
            'lotus-tag',
            `lotus-tag-${type}`,
            `lotus-tag-${size}`,
            `lotus-tag-${shape}`,
            color === 'white' && !colorful ? 'lotus-tag-white' : '',
            colorful ? 'lotus-tag-colorful' : '',
            colorful && gradient ? 'lotus-tag-colorful-gradient' : '',
            className ?? '',
        ]
            .filter(Boolean)
            .join(' '),
    );

    // clickable 决定是否需要键盘可达性（role=button + tabIndex + 键盘事件）：
    // 对齐 Semi 只在真的可交互（有 onClick 或 closable）时才把 Tag 纳入 Tab
    // 序，纯展示用的 Tag 不应该抢占键盘焦点。
    const clickable = onClick !== undefined || closable;

    function handleClose(event: MouseEvent | KeyboardEvent) {
        event.stopPropagation();
        if (!isControlledVisible) {
            internalVisible = false;
        }
        onClose?.(children, event, tagKey);
    }

    // 对齐 Semi handleKeyDown：Backspace/Delete 关闭（closable 时），Enter
    // 触发 onClick，Escape 失焦——只在 clickable 时绑定，避免纯展示 Tag
    // 意外响应键盘事件。
    function handleKeyDown(event: KeyboardEvent) {
        switch (event.key) {
            case 'Backspace':
            case 'Delete':
                if (closable) {
                    event.preventDefault();
                    handleClose(event);
                }
                break;
            case 'Enter':
                event.preventDefault();
                onClick?.(event as any);
                break;
            case 'Escape':
                (event.target as HTMLElement)?.blur();
                break;
        }
        onKeyDown?.(event);
    }

    <>
        @if (visible) {
            <div
                class={classes}
                style={{ ...style, '--lotus-tag-color': colorful || color === 'white' ? '' : `var(--lotus-color-tag-${kebabCase(color)})` }}
                onClick={onClick}
                onMouseEnter={onMouseEnter}
                aria-label={ariaLabel}
                role={clickable ? 'button' : undefined}
                tabIndex={clickable ? (tabIndex ?? 0) : tabIndex}
                onKeyDown={clickable ? handleKeyDown : onKeyDown}
            >
                @if (prefixIcon) {
                    <span class="lotus-tag-prefix-icon">
                        {prefixIcon}
                    </span>
                }
                @if (avatarSrc) {
                    <span class="lotus-tag-avatar">
                        <Avatar src={avatarSrc} shape={avatarShape} size="extra-small" />
                    </span>
                }
                <span class="lotus-tag-content">{children}</span>
                @if (suffixIcon && !closable) {
                    <span class="lotus-tag-suffix-icon">
                        {suffixIcon}
                    </span>
                }
                @if (closable) {
                    <button
                        type="button"
                        class="lotus-tag-close"
                        aria-label={locale.Tag.close}
                        onClick={handleClose}
                    >
                        <IconClose />
                    </button>
                }
            </div>
        }

        <style>
            .lotus-tag {
                display: inline-flex;
                align-items: center;
                gap: 4px;
                box-sizing: border-box;
                border-radius: var(--lotus-border-radius-small);
                font-size: var(--lotus-font-label-size);
                line-height: var(--lotus-font-label-line-height);
                white-space: nowrap;
            }

            .lotus-tag-default {
                height: 24px;
                padding: 0 8px;
            }

            .lotus-tag-small {
                height: 20px;
                padding: 0 6px;
            }

            .lotus-tag-large {
                height: 28px;
                padding: 0 10px;
                font-size: var(--lotus-font-body-size);
            }

            .lotus-tag-circle {
                border-radius: var(--lotus-border-radius-full);
            }

            .lotus-tag-avatar {
                display: inline-flex;
                align-items: center;
                margin-inline-start: -4px;
            }

            /* light：浅底深字，默认主题 */
            .lotus-tag-light {
                background: color-mix(in srgb, var(--lotus-tag-color, var(--lotus-color-tertiary)) 12%, var(--lotus-color-bg-1));
                color: var(--lotus-tag-color, var(--lotus-color-tertiary));
            }

            /* solid：实心色块，白字 */
            .lotus-tag-solid {
                background: var(--lotus-tag-color, var(--lotus-color-tertiary));
                color: #ffffff;
            }

            /* ghost：透明底，描边，深字 */
            .lotus-tag-ghost {
                background: transparent;
                color: var(--lotus-tag-color, var(--lotus-color-tertiary));
                border: 1px solid var(--lotus-tag-color, var(--lotus-color-tertiary));
            }

            .lotus-tag-white {
                background: var(--lotus-color-bg-1);
                color: var(--lotus-color-text-0);
                border: 1px solid var(--lotus-color-border);
            }

            /* ---- colorful：AI 多彩风格，忽略 color 语义色，solid 纯色/light 浅底+紫字/
               ghost 白底描边+紫字；colorful-gradient 时三者均改用渐变 ---- */
            .lotus-tag-colorful.lotus-tag-solid {
                background: var(--lotus-color-ai-purple);
                color: #ffffff;
                font-weight: var(--lotus-font-weight-semibold);
            }
            .lotus-tag-colorful-gradient.lotus-tag-solid {
                background: var(--lotus-color-ai-general);
            }

            .lotus-tag-colorful.lotus-tag-light {
                background: var(--lotus-color-ai-background-top);
                color: var(--lotus-color-ai-purple);
                font-weight: var(--lotus-font-weight-semibold);
            }
            .lotus-tag-colorful-gradient.lotus-tag-light {
                background: var(--lotus-color-ai-background-top);
                background-image: var(--lotus-color-ai-general);
                background-clip: text;
                -webkit-background-clip: text;
                color: transparent;
                -webkit-text-fill-color: transparent;
            }

            .lotus-tag-colorful.lotus-tag-ghost {
                background: var(--lotus-color-bg-1);
                color: var(--lotus-color-ai-purple);
                border-color: var(--lotus-color-ai-purple);
                font-weight: var(--lotus-font-weight-semibold);
            }
            .lotus-tag-colorful-gradient.lotus-tag-ghost {
                background: var(--lotus-color-bg-1);
                background-image: var(--lotus-color-ai-general);
                background-clip: text;
                -webkit-background-clip: text;
                color: transparent;
                -webkit-text-fill-color: transparent;
                border-color: var(--lotus-color-ai-purple);
            }

            .lotus-tag-prefix-icon,
            .lotus-tag-suffix-icon {
                display: inline-flex;
                align-items: center;
            }

            .lotus-tag-close {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                border: none;
                background: transparent;
                padding: 0;
                margin-inline-start: 2px;
                color: currentColor;
                opacity: 0.6;
                cursor: pointer;
            }

            .lotus-tag-close:hover {
                opacity: 1;
            }
        </style>
    </>
}

function kebabCase(s: string): string {
    return s.replace(/([a-z0-9])([A-Z])/g, '$1-$2').toLowerCase();
}
