import { track } from 'ripple';
import { IconChevronRight } from '@lotus/icons';
import type { JsonNode } from '@lotus/foundation/show/json-viewer';

export interface JsonNodeViewProps {
    node: JsonNode;
    expandedPaths: Set<string>;
    onToggleExpand: (path: string) => void;
    isLast: boolean;
}

function valueClassName(node: JsonNode): string {
    return `lotus-json-viewer-value lotus-json-viewer-value-${node.type}`;
}

function formatLeafValue(node: JsonNode): string {
    if (node.type === 'string') return `"${node.value as string}"`;
    if (node.type === 'null') return 'null';
    return String(node.value);
}

/**
 * 递归渲染单个 JSON 节点：容器节点（object/array）带展开/折叠开关，展开时
 * 递归渲染子节点；叶子节点（string/number/boolean/null）按类型套上语义 class
 * 做着色，不需要动态标签语法（不像 hast 树标签名是运行时变量，JSON 节点固定
 * 用 li/span 结构，只是 class 名按类型变化）。
 */
export function JsonNodeView(&{ node, expandedPaths, onToggleExpand, isLast }: JsonNodeViewProps) @{
    const isContainer = node.type === 'object' || node.type === 'array';
    const bracketOpen = node.type === 'object' ? '{' : '[';
    const bracketClose = node.type === 'object' ? '}' : ']';
    // expandedPaths 是父组件传下来的响应式 Set，随展开/折叠操作整体替换引用；
    // 必须用 track() 包裹才能在其变化时重新求值——顶层 const 只在组件首次
    // 挂载时计算一次，之后 expandedPaths 换了新引用也不会重新读取 .has()。
    let &[expanded] = track<boolean>(() => expandedPaths.has(node.path));

    <>
    <li class="lotus-json-viewer-node" data-path={node.path}>
        @if (isContainer) {
            <>
                <span
                    class={['lotus-json-viewer-switcher', expanded ? 'lotus-json-viewer-switcher-expanded' : ''].filter(Boolean).join(' ')}
                    role="button"
                    tabIndex={0}
                    aria-expanded={expanded}
                    aria-label={expanded ? '折叠节点' : '展开节点'}
                    onClick={() => onToggleExpand(node.path)}
                    onKeyDown={(e: KeyboardEvent) => {
                        if (e.key === 'Enter' || e.key === ' ') {
                            e.preventDefault();
                            onToggleExpand(node.path);
                        }
                    }}
                >
                    <IconChevronRight />
                </span>
                @if (node.parentKind === 'object') {
                    <>
                        <span class="lotus-json-viewer-key">{node.key}</span>
                        <span class="lotus-json-viewer-colon">:</span>
                    </>
                }
                <span class="lotus-json-viewer-bracket">{bracketOpen}</span>
                @if (!expanded) {
                    <>
                        <span class="lotus-json-viewer-collapsed-summary">
                            {node.type === 'object' ? `${node.children.length} 个属性` : `${node.children.length} 项`}
                        </span>
                        <span class="lotus-json-viewer-bracket">{bracketClose}</span>
                    </>
                }
                @if (expanded) {
                    <>
                        <ul class="lotus-json-viewer-children">
                            @for (const child of node.children; key child.path) {
                                <JsonNodeView
                                    node={child}
                                    expandedPaths={expandedPaths}
                                    onToggleExpand={onToggleExpand}
                                    isLast={child.path === node.children[node.children.length - 1]?.path}
                                />
                            }
                        </ul>
                        <span class="lotus-json-viewer-bracket lotus-json-viewer-bracket-close-line">{bracketClose}</span>
                    </>
                }
            </>
        } @else {
            <>
                <span class="lotus-json-viewer-switcher lotus-json-viewer-switcher-placeholder" />
                @if (node.parentKind === 'object') {
                    <>
                        <span class="lotus-json-viewer-key">{node.key}</span>
                        <span class="lotus-json-viewer-colon">:</span>
                    </>
                }
                <span class={valueClassName(node)}>{formatLeafValue(node)}</span>
            </>
        }
        @if (!isLast) {
            <span class="lotus-json-viewer-comma">,</span>
        }
    </li>
    </>
}
