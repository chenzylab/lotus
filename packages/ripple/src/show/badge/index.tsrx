import { track } from 'ripple';
import { shouldShowBadge, isCustomContent, formatCount } from '@lotus/foundation/show/badge';

export type BadgeType = 'primary' | 'secondary' | 'tertiary' | 'danger' | 'warning' | 'success';
export type BadgeTheme = 'solid' | 'light' | 'inverted';
export type BadgePosition = 'leftTop' | 'leftBottom' | 'rightTop' | 'rightBottom';

export interface BadgeProps {
    children?: any;
    count?: any;
    dot?: boolean;
    overflowCount?: number;
    position?: BadgePosition;
    type?: BadgeType;
    theme?: BadgeTheme;
    className?: string;
    countClassName?: string;
    style?: Record<string, any>;
    countStyle?: Record<string, any>;
    onClick?: (event: MouseEvent) => void;
    onMouseEnter?: (event: MouseEvent) => void;
    onMouseLeave?: (event: MouseEvent) => void;
    'aria-label'?: string;
}

export function Badge(&{
    children,
    count,
    dot = false,
    overflowCount,
    position = 'rightTop',
    type = 'primary',
    theme = 'solid',
    className,
    countClassName,
    style,
    countStyle,
    onClick,
    onMouseEnter,
    onMouseLeave,
    'aria-label': ariaLabel,
}: BadgeProps) @{
    const hasChildren = children !== undefined && children !== null;

    let &[visible] = track<boolean>(() => shouldShowBadge(count, dot));
    let &[custom] = track<boolean>(() => isCustomContent(count));
    let &[text] = track<string>(() => formatCount(count, overflowCount));

    let &[wrapperClasses] = track<string>(() =>
        ['lotus-badge', hasChildren ? '' : 'lotus-badge-block', className ?? ''].filter(Boolean).join(' '),
    );

    let &[countClasses] = track<string>(() =>
        [
            'lotus-badge-count',
            dot ? 'lotus-badge-dot' : '',
            custom ? 'lotus-badge-custom' : `lotus-badge-${type} lotus-badge-${theme}`,
            hasChildren ? `lotus-badge-${position}` : '',
            countClassName ?? '',
        ]
            .filter(Boolean)
            .join(' '),
    );

    let &[countStyleValue] = track<Record<string, any> | undefined>(() => style ?? countStyle);

    const countAriaLabel = dot ? '有未读消息' : typeof count === 'string' || typeof count === 'number' ? String(count) : undefined;

    let &[displayContent] = track<any>(() => (dot ? '' : custom ? count : text));

    <>
        <span class={wrapperClasses} onClick={onClick} onMouseEnter={onMouseEnter} onMouseLeave={onMouseLeave} aria-label={ariaLabel}>
            {children}
            @if (visible) {
                <span class={countClasses} style={countStyleValue} role="status" aria-label={countAriaLabel}>
                    {displayContent}
                </span>
            }
        </span>

        <style>
            .lotus-badge {
                position: relative;
                display: inline-flex;
                line-height: 1;
            }

            .lotus-badge-block {
                display: inline-block;
            }

            .lotus-badge-count {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                box-sizing: border-box;
                min-width: 16px;
                height: 16px;
                padding: 0 4px;
                border-radius: 8px;
                font-size: 11px;
                font-weight: 600;
                line-height: 1;
                white-space: nowrap;
            }

            .lotus-badge-block .lotus-badge-count {
                position: static;
            }

            .lotus-badge-dot {
                min-width: 6px;
                width: 6px;
                height: 6px;
                padding: 0;
                border-radius: 50%;
            }

            .lotus-badge-custom {
                min-width: 16px;
                height: 16px;
                padding: 0;
                border-radius: 50%;
                background: transparent;
            }

            .lotus-badge-rightTop {
                position: absolute;
                top: 0;
                right: 0;
                transform: translate(50%, -50%);
            }

            .lotus-badge-rightBottom {
                position: absolute;
                bottom: 0;
                right: 0;
                transform: translate(50%, 50%);
            }

            .lotus-badge-leftTop {
                position: absolute;
                top: 0;
                left: 0;
                transform: translate(-50%, -50%);
            }

            .lotus-badge-leftBottom {
                position: absolute;
                bottom: 0;
                left: 0;
                transform: translate(-50%, 50%);
            }

            .lotus-badge-primary.lotus-badge-solid { background: var(--lotus-color-primary); color: #ffffff; }
            .lotus-badge-secondary.lotus-badge-solid { background: var(--lotus-color-secondary); color: #ffffff; }
            .lotus-badge-tertiary.lotus-badge-solid { background: var(--lotus-color-tertiary); color: #ffffff; }
            .lotus-badge-danger.lotus-badge-solid { background: var(--lotus-color-danger); color: #ffffff; }
            .lotus-badge-warning.lotus-badge-solid { background: var(--lotus-color-warning); color: #ffffff; }
            .lotus-badge-success.lotus-badge-solid { background: var(--lotus-color-success); color: #ffffff; }

            .lotus-badge-primary.lotus-badge-light { background: var(--lotus-color-primary-light-default); color: var(--lotus-color-primary); }
            .lotus-badge-secondary.lotus-badge-light { background: var(--lotus-color-secondary-light-default); color: var(--lotus-color-secondary); }
            .lotus-badge-tertiary.lotus-badge-light { background: var(--lotus-color-tertiary-light-default); color: var(--lotus-color-tertiary); }
            .lotus-badge-danger.lotus-badge-light { background: var(--lotus-color-danger-light-default); color: var(--lotus-color-danger); }
            .lotus-badge-warning.lotus-badge-light { background: var(--lotus-color-warning-light-default); color: var(--lotus-color-warning); }
            .lotus-badge-success.lotus-badge-light { background: var(--lotus-color-success-light-default); color: var(--lotus-color-success); }

            .lotus-badge-primary.lotus-badge-inverted { background: transparent; color: var(--lotus-color-primary); border: 1px solid var(--lotus-color-primary); }
            .lotus-badge-secondary.lotus-badge-inverted { background: transparent; color: var(--lotus-color-secondary); border: 1px solid var(--lotus-color-secondary); }
            .lotus-badge-tertiary.lotus-badge-inverted { background: transparent; color: var(--lotus-color-tertiary); border: 1px solid var(--lotus-color-tertiary); }
            .lotus-badge-danger.lotus-badge-inverted { background: transparent; color: var(--lotus-color-danger); border: 1px solid var(--lotus-color-danger); }
            .lotus-badge-warning.lotus-badge-inverted { background: transparent; color: var(--lotus-color-warning); border: 1px solid var(--lotus-color-warning); }
            .lotus-badge-success.lotus-badge-inverted { background: transparent; color: var(--lotus-color-success); border: 1px solid var(--lotus-color-success); }

            .lotus-badge-dot.lotus-badge-primary { background: var(--lotus-color-primary); }
            .lotus-badge-dot.lotus-badge-secondary { background: var(--lotus-color-secondary); }
            .lotus-badge-dot.lotus-badge-tertiary { background: var(--lotus-color-tertiary); }
            .lotus-badge-dot.lotus-badge-danger { background: var(--lotus-color-danger); }
            .lotus-badge-dot.lotus-badge-warning { background: var(--lotus-color-warning); }
            .lotus-badge-dot.lotus-badge-success { background: var(--lotus-color-success); }
        </style>
    </>
}
