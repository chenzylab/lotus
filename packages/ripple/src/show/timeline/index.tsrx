import { track } from 'ripple';
import { TimelineItem } from './item.tsrx';
import { TimelineContext, type TimelineContextValue } from './timeline-context.js';
import type { TimelineItemType, TimelinePosition } from './item.tsrx';

export type TimelineMode = 'left' | 'right' | 'center' | 'alternate';

export interface TimelineDataItem {
    content?: any;
    time?: any;
    type?: TimelineItemType;
    color?: string;
    dot?: any;
    extra?: any;
    position?: TimelinePosition;
    class?: string;
    style?: Record<string, any>;
    onClick?: (event: MouseEvent) => void;
}

export interface TimelineProps {
    children?: any;
    dataSource?: TimelineDataItem[];
    mode?: TimelineMode;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

export function Timeline(&{
    children,
    dataSource,
    mode = 'left',
    style,
    class: className,
    'aria-label': ariaLabel,
}: TimelineProps) @{
    let &[classes] = track<string>(() => ['lotus-timeline', className ?? ''].filter(Boolean).join(' '));
    // 对齐 Semi：dataSource 与 children 互斥，dataSource 非空时完全忽略 children。
    let &[items] = track<TimelineDataItem[]>(() => (dataSource && dataSource.length ? dataSource : []));
    const useDataSource = dataSource !== undefined && dataSource.length > 0;

    let &[, contextTracked] = track<TimelineContextValue>(() => ({ mode }));
    TimelineContext.set(contextTracked);

    <>
        <ul class={classes} style={style} aria-label={ariaLabel}>
            @if (useDataSource) {
                @for (const item of items; index i) {
                    <TimelineItem
                        index={i}
                        time={item.time}
                        type={item.type}
                        color={item.color}
                        dot={item.dot}
                        extra={item.extra}
                        position={item.position}
                        class={item.class}
                        style={item.style}
                        onClick={item.onClick}
                    >
                        {item.content}
                    </TimelineItem>
                }
            }
            @if (!useDataSource) {
                <>{children}</>
            }
        </ul>

        <style>
            .lotus-timeline {
                margin: 0;
                padding: 0;
                list-style: none;
            }
        </style>
    </>
}
