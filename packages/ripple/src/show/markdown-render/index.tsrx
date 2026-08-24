import { track, effect } from 'ripple';
import { compileToHast, type HastRoot, type UnifiedPluginEntry } from '@lotus/foundation/show/markdown-render';
import { HastNode } from './hast-node.tsrx';

export type { UnifiedPluginEntry };

export interface MarkdownRenderProps {
    raw?: string;
    remarkGfm?: boolean;
    remarkPlugins?: UnifiedPluginEntry[];
    rehypePlugins?: UnifiedPluginEntry[];
    class?: string;
    style?: Record<string, any>;
}

export function MarkdownRender(&{
    raw = '',
    remarkGfm = true,
    remarkPlugins,
    rehypePlugins,
    class: className,
    style,
}: MarkdownRenderProps) @{
    let &[hast] = track<HastRoot | null>(null);

    // raw/remarkGfm/插件变化即重新编译；用 stale 标记丢弃过期的异步结果（对齐
    // 竞态防护惯例：连续快速修改 raw 时，只有最后一次发起的编译结果会被采用）。
    effect(() => {
        const currentRaw = raw;
        const currentGfm = remarkGfm;
        const currentRemarkPlugins = remarkPlugins;
        const currentRehypePlugins = rehypePlugins;
        let stale = false;

        compileToHast(currentRaw, {
            remarkGfm: currentGfm,
            remarkPlugins: currentRemarkPlugins,
            rehypePlugins: currentRehypePlugins,
        })
            .then((result) => {
                if (!stale) hast = result;
            })
            .catch(() => {
                if (!stale) hast = null;
            });

        return () => {
            stale = true;
        };
    });

    <>
        <div class={['lotus-markdown-render', className ?? ''].filter(Boolean).join(' ')} style={style}>
            @if (hast) {
                <HastNode node={hast} />
            }
        </div>

        <style>
            .lotus-markdown-render :global(.lotus-markdown-render-simple-code) {
                background: var(--lotus-color-fill-1);
                color: var(--lotus-color-danger);
                padding: 0.1em 0.4em;
                border-radius: var(--lotus-border-radius-small);
                font-family: ui-monospace, 'SFMono-Regular', 'SF Mono', Menlo, Monaco, Consolas, 'Liberation Mono', 'DejaVu Sans Mono', 'Courier New', monospace;
                font-size: 0.9em;
            }

            .lotus-markdown-render :global(table) {
                border-collapse: collapse;
                width: 100%;
            }

            .lotus-markdown-render :global(th),
            .lotus-markdown-render :global(td) {
                border: 1px solid var(--lotus-color-border);
                padding: 6px 12px;
                text-align: left;
            }

            .lotus-markdown-render :global(blockquote) {
                margin: 0;
                padding: 0 1em;
                color: var(--lotus-color-text-2);
                border-left: 4px solid var(--lotus-color-border);
            }

            .lotus-markdown-render :global(img) {
                max-width: 100%;
            }

            .lotus-markdown-render :global(a) {
                color: var(--lotus-color-primary);
            }
        </style>
    </>
}
