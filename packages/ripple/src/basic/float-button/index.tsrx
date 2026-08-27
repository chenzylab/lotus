import { track } from 'ripple';
import { FloatButtonFoundation } from '@lotus/foundation/basic/float-button';

export type FloatButtonShape = 'square' | 'round';
export type FloatButtonSize = 'small' | 'default' | 'large';

export interface FloatButtonProps {
    icon?: any;
    shape?: FloatButtonShape;
    size?: FloatButtonSize;
    colorful?: boolean;
    disabled?: boolean;
    href?: string;
    target?: string;
    onClick?: (event: MouseEvent) => void;
    /** 必填——FloatButton 是纯图标按钮（无文本插槽），图标本身对屏幕阅读器
     * 是 aria-hidden，省略 aria-label 会让按钮对屏幕阅读器用户完全不可辨识
     * （对齐 IconButton 同等的类型层强制，之前误设为可选是真实无障碍缺口）。 */
    'aria-label': string;
    style?: Record<string, any>;
    class?: string;
}

/**
 * FloatButton：固定定位的悬浮操作按钮。不新建复杂 Foundation 状态机——
 * 点击拦截逻辑与 Button 同量级（仅 disabled 判断），`href` 跳转的具体
 * 执行（window.open/window.location.href）留在 Adapter 层，因为 Foundation
 * 必须保持 DOM 无关、可脱离浏览器环境单测。
 */
export function FloatButton(&{
    icon,
    shape = 'round',
    size = 'default',
    colorful = false,
    disabled = false,
    href,
    target,
    onClick,
    'aria-label': ariaLabel,
    style,
    class: className,
}: FloatButtonProps) @{
    // 直接实时读 prop（非函数字面量 track() 会在挂载时固化快照，disabled
    // 运行时变化后 FloatButtonFoundation.handleClick 读到的判断依据会永远是
    // 挂载时刻的旧值——同一根因已在 Button 组件排查确认，详见 specs 踩坑 #94）。
    const foundation = new FloatButtonFoundation({
        getState: () => ({ disabled }),
        setState: () => {},
    });

    function handleClick(event: MouseEvent) {
        foundation.handleClick(() => {
            if (href) {
                if (target === '_blank') {
                    window.open(href, '_blank', 'noopener,noreferrer');
                } else {
                    window.location.href = href;
                }
            }
            onClick?.(event);
        });
    }

    let &[classes] = track<string>(() =>
        [
            'lotus-float-button',
            `lotus-float-button-shape-${shape}`,
            `lotus-float-button-size-${size}`,
            colorful ? 'lotus-float-button-colorful' : '',
            disabled ? 'lotus-float-button-disabled' : '',
            className ?? '',
        ]
            .filter(Boolean)
            .join(' '),
    );

    <>
        <button
            type="button"
            class={classes}
            style={style}
            disabled={disabled}
            aria-label={ariaLabel}
            onClick={handleClick}
        >
            <span class="lotus-float-button-icon">{icon}</span>
        </button>

        <style>
            .lotus-float-button {
                position: fixed;
                right: 24px;
                bottom: 24px;
                z-index: var(--lotus-z-back-top);
                display: inline-flex;
                align-items: center;
                justify-content: center;
                box-sizing: border-box;
                width: var(--lotus-height-control-large);
                height: var(--lotus-height-control-large);
                padding: 0;
                border: none;
                border-radius: var(--lotus-border-radius-full);
                background: var(--lotus-color-bg-1);
                color: var(--lotus-color-text-0);
                box-shadow: var(--lotus-shadow-elevated);
                cursor: pointer;
                transition: background-color 0.2s ease, box-shadow 0.2s ease;
            }

            .lotus-float-button-shape-square {
                border-radius: var(--lotus-border-radius-medium);
            }

            .lotus-float-button-size-small {
                width: var(--lotus-height-control-default);
                height: var(--lotus-height-control-default);
            }

            .lotus-float-button-size-large {
                width: 48px;
                height: 48px;
            }

            .lotus-float-button-icon {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                font-size: var(--lotus-font-body-size);
            }

            .lotus-float-button:hover:not(:disabled) {
                background: var(--lotus-color-fill-1);
            }

            .lotus-float-button:active:not(:disabled) {
                background: var(--lotus-color-fill-2);
            }

            .lotus-float-button-colorful {
                background: var(--lotus-color-ai-general);
                color: #ffffff;
            }

            .lotus-float-button-colorful:hover:not(:disabled) {
                background: var(--lotus-color-ai-general-hover);
            }

            .lotus-float-button-colorful:active:not(:disabled) {
                background: var(--lotus-color-ai-general-active);
            }

            .lotus-float-button-disabled,
            .lotus-float-button:disabled {
                cursor: not-allowed;
                color: var(--lotus-color-disabled-text);
                background: var(--lotus-color-disabled-bg);
                box-shadow: none;
            }
        </style>
    </>
}
