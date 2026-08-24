import type { Element, ElementContent, Root, RootContent } from 'hast';
import { hastPropsToAttrs } from '@lotus/foundation/show/markdown-render';
import { CodeHighlight } from '../code-highlight/index.tsrx';

/**
 * hast <code> 节点里的语言名解析：className 里找 `language-xxx`，取最后一段
 * （对齐 Semi markdownRender/components/code.tsx 的 nth(className.split('-'), -1)）。
 */
function getCodeLanguage(node: Element | undefined): string | undefined {
    if (!node) return undefined;
    const className = (node.properties?.className as string[] | undefined) ?? [];
    const languageClass = className.find((c) => c.startsWith('language-'));
    if (!languageClass) return undefined;
    const parts = languageClass.split('-');
    return parts[parts.length - 1];
}

function extractText(node: ElementContent): string {
    if (node.type === 'text') return node.value;
    if (node.type === 'element') return node.children.map(extractText).join('');
    return '';
}

/**
 * code 节点覆盖：有 language-* 类（围栏代码块）→ CodeHighlight（自带 pre>code，
 * 不再嵌套外层原生 pre，与 chenzy.design/Semi 的"不覆盖 pre 键"策略不同——
 * lotus 的 CodeHighlight 自身就是完整的 pre>code 结构，覆盖点从 code 上移到
 * pre，覆盖时直接跳过 hast 树里的原生 pre 包裹，避免出现 pre 套 pre）。
 * 无 language-*（行内 code）→ span.lotus-markdown-render-simple-code。
 */
export function MarkdownCodeBlock(&{ node }: { node: Element }) @{
    const language = getCodeLanguage(node);
    const code = extractText(node);

    @if (language) {
        <CodeHighlight code={code} language={language} lineNumber={true} />
    } @else {
        <span class="lotus-markdown-render-simple-code">{code}</span>
    }
}

/**
 * 递归渲染单个 hast 节点：element 用动态标签语法 `<{tagName}>`（tsrx 原生支持
 * 标签名读运行时字符串/成员表达式），text 直接渲染文本，root 渲染其 children，
 * 其余节点类型（raw/comment/doctype 等）一律跳过——对齐 Semi format='md' 不
 * 渲染 raw HTML 的行为，也是本组件 XSS 防护的最后一道防线（即便 hast 树里
 * 意外出现了 raw 节点，渲染层也没有任何会把它当 HTML 解析执行的代码路径）。
 */
export function HastNode(&{ node }: { node: Root | RootContent }) @{
    @if (node.type === 'text') {
        <>{node.value}</>
    } @else {
        @if (node.type === 'root') {
            <>
                @for (const child of node.children; index i) {
                    <HastNode node={child} />
                }
            </>
        } @else {
            @if (node.type === 'element') {
                @if (node.tagName === 'pre' && node.children.some((c) => c.type === 'element' && c.tagName === 'code')) {
                    <MarkdownCodeBlock node={node.children.find((c) => c.type === 'element' && c.tagName === 'code') as Element} />
                } @else {
                    @if (node.tagName === 'code') {
                        <MarkdownCodeBlock node={node} />
                    } @else {
                        <{node.tagName} {...hastPropsToAttrs(node.properties as Record<string, unknown>)}>
                            @for (const child of node.children; index i) {
                                <HastNode node={child} />
                            }
                        </{node.tagName}>
                    }
                }
            }
        }
    }
}
