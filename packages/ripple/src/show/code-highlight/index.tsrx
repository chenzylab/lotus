import { effect } from 'ripple';
import { resolveCodeClassName } from '@lotus/foundation/show/code-highlight';
import Prism from 'prismjs';
import 'prismjs/components/prism-markup.js';
import 'prismjs/components/prism-clike.js';
import 'prismjs/components/prism-javascript.js';
import 'prismjs/components/prism-css.js';
import 'prismjs/components/prism-typescript.js';
import 'prismjs/components/prism-markup-templating.js';
import 'prismjs/components/prism-jsx.js';
import 'prismjs/components/prism-tsx.js';
import 'prismjs/components/prism-bash.js';
import 'prismjs/components/prism-json.js';
import 'prismjs/plugins/line-numbers/prism-line-numbers.js';

// Semi 对齐：手动高亮，禁止 Prism 自动扫描 DOM。
Prism.manual = true;

export interface CodeHighlightProps {
    code?: string;
    language?: string;
    lineNumber?: boolean;
    defaultTheme?: boolean;
    class?: string;
    style?: Record<string, any>;
}

export function CodeHighlight(&{
    code = '',
    language = 'markup',
    lineNumber = true,
    defaultTheme = true,
    class: className,
    style,
}: CodeHighlightProps) @{
    let codeEl: HTMLElement | null = null;

    // 就地高亮：设 class + 写纯文本节点，再交给 Prism 处理，绝不经 innerHTML/{@html}，规避 XSS。
    effect(() => {
        const el = codeEl;
        if (!el) return;
        const nextCode = code;
        const nextLang = language;
        const nextLineNumber = lineNumber;

        el.className = resolveCodeClassName('', nextLang, nextLineNumber);
        el.textContent = nextCode;
        Prism.highlightElement(el, false);
    });

    <>
        <div
            class={['lotus-code-highlight', defaultTheme ? 'lotus-code-highlight-defaultTheme' : '', className ?? ''].filter(Boolean).join(' ')}
            style={style}
        >
            <pre class={lineNumber ? 'line-numbers' : ''}>
                <code ref={(node: HTMLElement | null) => { codeEl = node; }}></code>
            </pre>
        </div>

        <style>
            .lotus-code-highlight :global(pre) {
                margin: 0;
            }

            .lotus-code-highlight-defaultTheme :global(pre[class*='language-']),
            .lotus-code-highlight-defaultTheme :global(code[class*='language-']) {
                color: var(--lotus-color-text-0);
                font-size: 13px;
                text-shadow: none;
                font-family: ui-monospace, 'SFMono-Regular', 'SF Mono', Menlo, Monaco, Consolas, 'Liberation Mono', 'DejaVu Sans Mono', 'Courier New', monospace;
                direction: ltr;
                text-align: left;
                white-space: pre;
                word-spacing: normal;
                word-break: normal;
                line-height: 1.5;
                tab-size: 4;
                hyphens: none;
            }

            .lotus-code-highlight-defaultTheme :global(pre[class*='language-']::selection),
            .lotus-code-highlight-defaultTheme :global(code[class*='language-']::selection) {
                text-shadow: none;
                background: #b3d4fc;
            }

            .lotus-code-highlight-defaultTheme :global(pre[class*='language-']) {
                padding: 1em;
                margin: 0.5em 0;
                overflow: auto;
                background: var(--lotus-color-fill-1);
            }

            .lotus-code-highlight-defaultTheme :global(:not(pre) > code[class*='language-']) {
                display: block;
                border-radius: 0.3em;
                color: #895fe2;
                background: #f9f7f9;
            }

            .lotus-code-highlight-defaultTheme :global(pre .namespace) {
                opacity: 0.7;
            }

            .lotus-code-highlight-defaultTheme :global(pre .token.comment),
            .lotus-code-highlight-defaultTheme :global(pre .token.prolog),
            .lotus-code-highlight-defaultTheme :global(pre .token.doctype),
            .lotus-code-highlight-defaultTheme :global(pre .token.cdata) {
                color: #6b7075;
            }

            .lotus-code-highlight-defaultTheme :global(pre .token.punctuation) {
                color: var(--lotus-color-text-2);
            }

            .lotus-code-highlight-defaultTheme :global(pre .token.property),
            .lotus-code-highlight-defaultTheme :global(pre .token.tag),
            .lotus-code-highlight-defaultTheme :global(pre .token.boolean),
            .lotus-code-highlight-defaultTheme :global(pre .token.number),
            .lotus-code-highlight-defaultTheme :global(pre .token.constant),
            .lotus-code-highlight-defaultTheme :global(pre .token.symbol),
            .lotus-code-highlight-defaultTheme :global(pre .token.deleted) {
                color: #895fe2;
            }

            .lotus-code-highlight-defaultTheme :global(pre .token.selector),
            .lotus-code-highlight-defaultTheme :global(pre .token.attr-name),
            .lotus-code-highlight-defaultTheme :global(pre .token.string),
            .lotus-code-highlight-defaultTheme :global(pre .token.char),
            .lotus-code-highlight-defaultTheme :global(pre .token.builtin),
            .lotus-code-highlight-defaultTheme :global(pre .token.inserted) {
                color: #2f9e44;
            }

            .lotus-code-highlight-defaultTheme :global(pre .token.operator),
            .lotus-code-highlight-defaultTheme :global(pre .token.entity),
            .lotus-code-highlight-defaultTheme :global(pre .token.url),
            .lotus-code-highlight-defaultTheme :global(pre .language-css .token.string),
            .lotus-code-highlight-defaultTheme :global(pre .style .token.string) {
                color: var(--lotus-color-text-2);
            }

            .lotus-code-highlight-defaultTheme :global(pre .token.atrule),
            .lotus-code-highlight-defaultTheme :global(pre .token.attr-value),
            .lotus-code-highlight-defaultTheme :global(pre .token.keyword) {
                color: #895fe2;
            }

            .lotus-code-highlight-defaultTheme :global(pre .token.function) {
                color: #7048e8;
            }

            .lotus-code-highlight-defaultTheme :global(pre .token.regex),
            .lotus-code-highlight-defaultTheme :global(pre .token.important),
            .lotus-code-highlight-defaultTheme :global(pre .token.variable) {
                color: #d0955f;
            }

            .lotus-code-highlight-defaultTheme :global(pre .token.important),
            .lotus-code-highlight-defaultTheme :global(pre .token.bold) {
                font-weight: bold;
            }

            .lotus-code-highlight-defaultTheme :global(pre .token.italic) {
                font-style: italic;
            }

            .lotus-code-highlight-defaultTheme :global(pre .token.entity) {
                cursor: help;
            }

            .lotus-code-highlight :global(pre[class*='language-'].line-numbers) {
                position: relative;
                padding-left: 3.8em;
                counter-reset: linenumber;
            }

            .lotus-code-highlight :global(pre[class*='language-'].line-numbers > code) {
                position: relative;
                white-space: inherit;
            }

            .lotus-code-highlight :global(.line-numbers .line-numbers-rows) {
                position: absolute;
                pointer-events: none;
                top: 0;
                font-size: 100%;
                left: -3.8em;
                width: 3em;
                letter-spacing: -1px;
                border-right: 1px solid #999;
                user-select: none;
            }

            .lotus-code-highlight :global(.line-numbers-rows > span) {
                display: block;
                counter-increment: linenumber;
            }

            .lotus-code-highlight :global(.line-numbers-rows > span::before) {
                content: counter(linenumber);
                color: #999;
                display: block;
                padding-right: 0.8em;
                text-align: right;
            }
        </style>
    </>
}
