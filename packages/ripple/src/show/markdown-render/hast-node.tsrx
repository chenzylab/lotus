import type { Element, ElementContent, Root, RootContent } from 'hast';
import { hastPropsToAttrs, extractTableFromHast } from '@lotus/foundation/show/markdown-render';
import { CodeHighlight } from '../code-highlight/index.tsrx';
import { TypographyTitle, type TitleHeading } from '../../basic/typography/title.tsrx';
import { TypographyParagraph } from '../../basic/typography/paragraph.tsrx';
import { TypographyText } from '../../basic/typography/text.tsrx';
import { Image } from '../image/index.tsrx';
import { Table } from '../table/index.tsrx';

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

/** 渲染一组 hast 子节点，用于作为 Typography/Table 等组件的 `children` prop 显式传入
 * （这些组件内部用 `{children}` 表达式渲染，不是 JSX 标签子节点写法，需要一个可作为
 * 单一表达式值传递的组件包装，而不能直接内联 `@for` 循环）。 */
function HastChildren(&{ nodes }: { nodes: ElementContent[] }) @{
    <>
        @for (const child of nodes; index i) {
            <HastNode node={child} />
        }
    </>
}

const HEADING_TAGS = new Set(['h1', 'h2', 'h3', 'h4', 'h5', 'h6']);

/** markdown 表格覆盖：把 hast `table` 节点提取的 columns/dataSource 交给 Table
 * 组件渲染（对齐 Semi markdownRender/components/table.tsx），而非原生 `<table>`。 */
function MarkdownTable(&{ node }: { node: Element }) @{
    const { columns, dataSource } = extractTableFromHast(node);
    <Table columns={columns} dataSource={dataSource} pagination={false} bordered />
}

/**
 * 递归渲染单个 hast 节点：element 用动态标签语法 `<{tagName}>`（tsrx 原生支持
 * 标签名读运行时字符串/成员表达式），text 直接渲染文本，root 渲染其 children，
 * 其余节点类型（raw/comment/doctype 等）一律跳过——对齐 Semi format='md' 不
 * 渲染 raw HTML 的行为，也是本组件 XSS 防护的最后一道防线（即便 hast 树里
 * 意外出现了 raw 节点，渲染层也没有任何会把它当 HTML 解析执行的代码路径）。
 *
 * h1~h6/p/a/img/table 覆盖为对应 lotus 组件渲染（对齐 Semi markdownRender/
 * components/ 下的设计：markdown 渲染出的元素统一走 Semi 组件体系，而非
 * 原生 DOM + CSS 样式化，保持与库内其它内容的视觉/交互一致性）。
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
                        @if (HEADING_TAGS.has(node.tagName)) {
                            <TypographyTitle heading={Number(node.tagName.slice(1)) as TitleHeading} class="lotus-markdown-render-heading" children={<HastChildren nodes={node.children} />} />
                        } @else {
                            @if (node.tagName === 'p') {
                                <TypographyParagraph class="lotus-markdown-render-p" children={<HastChildren nodes={node.children} />} />
                            } @else {
                                @if (node.tagName === 'a') {
                                    <TypographyText
                                        link={{ href: String(node.properties?.href ?? ''), target: node.properties?.target as string | undefined }}
                                        children={<HastChildren nodes={node.children} />}
                                    />
                                } @else {
                                    @if (node.tagName === 'img') {
                                        <div class="lotus-markdown-render-image">
                                            <Image
                                                src={String(node.properties?.src ?? '')}
                                                alt={String(node.properties?.alt ?? '')}
                                                width="100%"
                                            />
                                            @if (node.properties?.alt) {
                                                <div class="lotus-markdown-render-image-alt">{String(node.properties.alt)}</div>
                                            }
                                        </div>
                                    } @else {
                                        @if (node.tagName === 'table') {
                                            <MarkdownTable node={node} />
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
                }
            }
        }
    }
}
