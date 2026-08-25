import { track } from 'ripple';
import { IconClose } from '@lotus/icons';

export type TagColor =
    | 'amber' | 'blue' | 'cyan' | 'green' | 'grey' | 'indigo' | 'lightBlue' | 'lightGreen'
    | 'lime' | 'orange' | 'pink' | 'purple' | 'red' | 'teal' | 'violet' | 'yellow' | 'white';
export type TagType = 'ghost' | 'solid' | 'light';
export type TagSize = 'default' | 'small' | 'large';

export interface TagProps {
    children?: any;
    size?: TagSize;
    color?: TagColor;
    type?: TagType;
    closable?: boolean;
    visible?: boolean;
    /** AI 多彩风格（对齐 Semi `colorful`），生效时忽略 `color` 语义色，改用 AI 渐变色系。 */
    colorful?: boolean;
    /** 配合 `colorful` 使用：是否用渐变色而非纯色（对齐 Semi `gradient`），单独设置无效果。 */
    gradient?: boolean;
    onClose?: (event: MouseEvent) => void;
    onClick?: (event: MouseEvent) => void;
    prefixIcon?: any;
    suffixIcon?: any;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

export function Tag(&{
    children,
    size = 'default',
    color = 'grey',
    type = 'light',
    closable = false,
    visible: visibleProp,
    colorful = false,
    gradient = false,
    onClose,
    onClick,
    prefixIcon,
    suffixIcon,
    style,
    class: className,
    'aria-label': ariaLabel,
}: TagProps) @{
    const isControlledVisible = visibleProp !== undefined;
    let &[internalVisible] = track<boolean>(true);
    let &[visible] = track<boolean>(() => (isControlledVisible ? !!visibleProp : internalVisible));

    let &[classes] = track<string>(() =>
        [
            'lotus-tag',
            `lotus-tag-${type}`,
            `lotus-tag-${size}`,
            color === 'white' && !colorful ? 'lotus-tag-white' : '',
            colorful ? 'lotus-tag-colorful' : '',
            colorful && gradient ? 'lotus-tag-colorful-gradient' : '',
            className ?? '',
        ]
            .filter(Boolean)
            .join(' '),
    );

    const handleClose = (event: MouseEvent) => {
        event.stopPropagation();
        if (!isControlledVisible) {
            internalVisible = false;
        }
        onClose?.(event);
    };

    <>
        @if (visible) {
            <div
                class={classes}
                style={{ ...style, '--lotus-tag-color': colorful || color === 'white' ? '' : `var(--lotus-color-tag-${kebabCase(color)})` }}
                onClick={onClick}
                aria-label={ariaLabel}
            >
                @if (prefixIcon) {
                    <span class="lotus-tag-prefix-icon">
                        {prefixIcon}
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
                        aria-label="关闭标签"
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
                margin-left: 2px;
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
