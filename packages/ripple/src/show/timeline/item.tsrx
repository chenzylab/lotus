import { track } from 'ripple';
import { resolvePosition } from '@lotus/foundation/show/timeline';
import { TimelineContext } from './timeline-context.js';

export type TimelineItemType = 'default' | 'ongoing' | 'success' | 'warning' | 'error';
export type TimelinePosition = 'left' | 'right';

export interface TimelineItemProps {
    children?: any;
    time?: any;
    type?: TimelineItemType;
    color?: string;
    dot?: any;
    extra?: any;
    position?: TimelinePosition;
    /**
     * 该节点在时间轴中的序号，用于 mode=alternate 时的左右交替计算。
     * 通过 dataSource 渲染时由 Timeline 自动传入；直接用 JSX children
     * 方式（<Timeline><TimelineItem index={0} .../></Timeline>）时需要
     * 手动传入——Ripple 没有 React.Children.map，无法像 Semi 那样在父组件
     * 内自动推断每个子节点的序号。
     */
    index?: number;
    onClick?: (event: MouseEvent) => void;
    class?: string;
    style?: Record<string, any>;
}

export function TimelineItem(&{
    children,
    time,
    type = 'default',
    color,
    dot,
    extra,
    position: positionProp,
    index = 0,
    onClick,
    class: className,
    style,
}: TimelineItemProps) @{
    const contextTracked = TimelineContext.get();

    let &[mode] = track(() => contextTracked?.value.mode ?? 'left');
    let &[position] = track<TimelinePosition>(() => resolvePosition(mode, index, positionProp));
    const hasCustomDot = dot !== undefined;

    function handleClick(event: MouseEvent) {
        onClick?.(event);
    }

    let &[classes] = track<string>(() =>
        [
            'lotus-timeline-item',
            `lotus-timeline-item-${position}`,
            className ?? '',
        ].filter(Boolean).join(' '),
    );

    let &[dotClasses] = track<string>(() =>
        [
            'lotus-timeline-item-head',
            hasCustomDot ? 'lotus-timeline-item-head-custom' : `lotus-timeline-item-head-${type}`,
        ].filter(Boolean).join(' '),
    );

    let &[dotStyle] = track<Record<string, any> | undefined>(() => (color ? { backgroundColor: color } : undefined));

    <>
        <li class={classes} style={style} onClick={handleClick}>
            <div class="lotus-timeline-item-tail" aria-hidden="true" />
            <div class={dotClasses} style={dotStyle} aria-hidden="true">
                {dot}
            </div>
            <div class="lotus-timeline-item-content">
                <div class="lotus-timeline-item-children">{children}</div>
                @if (extra !== undefined) {
                    <div class="lotus-timeline-item-extra">{extra}</div>
                }
                @if (time !== undefined) {
                    <div class="lotus-timeline-item-time">{time}</div>
                }
            </div>
        </li>

        <style>
            .lotus-timeline-item {
                position: relative;
                display: flex;
                padding-bottom: var(--lotus-spacing-base-loose);
                list-style: none;
            }

            .lotus-timeline-item:last-child {
                padding-bottom: 0;
            }

            .lotus-timeline-item:last-child .lotus-timeline-item-tail {
                display: none;
            }

            .lotus-timeline-item-tail {
                position: absolute;
                top: 14px;
                left: 5px;
                bottom: -6px;
                width: 1px;
                background: var(--lotus-color-border);
            }

            .lotus-timeline-item-head {
                position: relative;
                z-index: 1;
                flex-shrink: 0;
                width: 11px;
                height: 11px;
                border-radius: var(--lotus-border-radius-circle);
                margin-top: 4px;
            }

            .lotus-timeline-item-head-default {
                background: var(--lotus-color-tertiary);
            }

            .lotus-timeline-item-head-ongoing {
                background: var(--lotus-color-primary);
            }

            .lotus-timeline-item-head-success {
                background: var(--lotus-color-success);
            }

            .lotus-timeline-item-head-warning {
                background: var(--lotus-color-warning);
            }

            .lotus-timeline-item-head-error {
                background: var(--lotus-color-danger);
            }

            .lotus-timeline-item-head-custom {
                width: auto;
                height: auto;
                display: flex;
                align-items: center;
                justify-content: center;
                background: transparent;
                margin-top: 0;
                transform: translateX(-4px);
            }

            .lotus-timeline-item-content {
                flex: 1;
                min-width: 0;
                margin-left: var(--lotus-spacing-tight);
            }

            .lotus-timeline-item-children {
                color: var(--lotus-color-text-0);
                font-size: var(--lotus-font-body-size);
            }

            .lotus-timeline-item-extra {
                margin-top: var(--lotus-spacing-super-tight);
                color: var(--lotus-color-text-1);
                font-size: var(--lotus-font-body-size);
            }

            .lotus-timeline-item-time {
                margin-top: var(--lotus-spacing-super-tight);
                color: var(--lotus-color-text-2);
                font-size: var(--lotus-font-label-size);
            }

            .lotus-timeline-item-right {
                flex-direction: row-reverse;
            }

            .lotus-timeline-item-right .lotus-timeline-item-content {
                margin-left: 0;
                margin-right: var(--lotus-spacing-tight);
                text-align: right;
            }

            .lotus-timeline-item-right .lotus-timeline-item-tail {
                left: auto;
                right: 5px;
            }
        </style>
    </>
}
