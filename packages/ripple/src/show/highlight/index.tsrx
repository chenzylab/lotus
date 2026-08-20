import { track } from 'ripple';
import {
    findHighlightChunks,
    type HighlightSearchWordInput,
    type HighlightChunk,
} from '@lotus/foundation/show/highlight';

export type { HighlightSearchWordInput };
export type HighlightComponent = 'mark' | 'span' | 'strong' | 'em';

export interface HighlightProps {
    sourceString?: string;
    searchWords?: HighlightSearchWordInput[];
    component?: HighlightComponent;
    highlightClassName?: string;
    highlightStyle?: Record<string, any>;
    caseSensitive?: boolean;
    autoEscape?: boolean;
    class?: string;
    style?: Record<string, any>;
    'aria-label'?: string;
}

function chunkClassName(chunk: HighlightChunk, highlightClassName?: string): string {
    return ['lotus-highlight-tag', highlightClassName ?? '', chunk.className ?? ''].filter(Boolean).join(' ');
}

function chunkStyle(chunk: HighlightChunk, highlightStyle?: Record<string, any>): Record<string, any> {
    return { ...highlightStyle, ...chunk.style };
}

export function Highlight(&{
    sourceString = '',
    searchWords = [],
    component = 'mark',
    highlightClassName,
    highlightStyle,
    caseSensitive = false,
    autoEscape = true,
    class: className,
    style,
    'aria-label': ariaLabel,
}: HighlightProps) @{
    let &[chunks] = track<HighlightChunk[]>(() =>
        findHighlightChunks(sourceString, searchWords, caseSensitive, autoEscape),
    );

    <>
        <span class={['lotus-highlight', className ?? ''].filter(Boolean).join(' ')} style={style} aria-label={ariaLabel}>
            @for (const chunk of chunks; index i) {
                <>
                    @if (!chunk.highlight) {
                        <>{sourceString.slice(chunk.start, chunk.end)}</>
                    }
                    @if (chunk.highlight && component === 'mark') {
                        <mark class={chunkClassName(chunk, highlightClassName)} style={chunkStyle(chunk, highlightStyle)}>
                            {sourceString.slice(chunk.start, chunk.end)}
                        </mark>
                    }
                    @if (chunk.highlight && component === 'span') {
                        <span class={chunkClassName(chunk, highlightClassName)} style={chunkStyle(chunk, highlightStyle)}>
                            {sourceString.slice(chunk.start, chunk.end)}
                        </span>
                    }
                    @if (chunk.highlight && component === 'strong') {
                        <strong class={chunkClassName(chunk, highlightClassName)} style={chunkStyle(chunk, highlightStyle)}>
                            {sourceString.slice(chunk.start, chunk.end)}
                        </strong>
                    }
                    @if (chunk.highlight && component === 'em') {
                        <em class={chunkClassName(chunk, highlightClassName)} style={chunkStyle(chunk, highlightStyle)}>
                            {sourceString.slice(chunk.start, chunk.end)}
                        </em>
                    }
                </>
            }
        </span>

        <style>
            .lotus-highlight-tag {
                background: var(--lotus-color-highlight-bg);
                color: var(--lotus-color-highlight);
                font-weight: 600;
            }
        </style>
    </>
}
