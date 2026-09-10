import { track, untrack } from 'ripple';
import { IconChevronRight } from '@lotus/icons';
import { parseLeafEditInput, type JsonNode } from '@lotus/foundation/show/json-viewer';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export interface JsonNodeViewProps {
    node: JsonNode;
    expandedPaths: Set<string>;
    onToggleExpand: (path: string) => void;
    isLast: boolean;
    /** 叶子节点是否可原地编辑（点击值区域进入编辑态）。 */
    editable?: boolean;
    /** 当前处于编辑态的节点路径，同一时间只允许一个节点编辑。 */
    editingPath?: string | null;
    onStartEdit?: (path: string) => void;
    onCommitEdit?: (path: string, rawInput: string) => void;
    onCancelEdit?: () => void;
    /** 当前搜索命中并高亮的节点路径。 */
    activeMatchPath?: string | null;
}

function valueClassName(node: JsonNode): string {
    return `lotus-json-viewer-value lotus-json-viewer-value-${node.type}`;
}

function formatLeafValue(node: JsonNode): string {
    if (node.type === 'string') return `"${node.value as string}"`;
    if (node.type === 'null') return 'null';
    return String(node.value);
}

/** 编辑框的初始内容：string 类型不带外层引号（用户直接编辑纯文本，对齐
 * parseLeafEditInput 把编辑框输入原样当字符串值的约定），其余类型保持
 * 原样展示（number/boolean/null 本身就是无引号字面量）。 */
function formatEditableValue(node: JsonNode): string {
    if (node.type === 'string') return node.value as string;
    if (node.type === 'null') return 'null';
    return String(node.value);
}

/**
 * 递归渲染单个 JSON 节点：容器节点（object/array）带展开/折叠开关，展开时
 * 递归渲染子节点；叶子节点（string/number/boolean/null）按类型套上语义 class
 * 做着色，不需要动态标签语法（不像 hast 树标签名是运行时变量，JSON 节点固定
 * 用 li/span 结构，只是 class 名按类型变化）。
 */
export function JsonNodeView(&{
    node,
    expandedPaths,
    onToggleExpand,
    isLast,
    editable = false,
    editingPath = null,
    onStartEdit,
    onCommitEdit,
    onCancelEdit,
    activeMatchPath = null,
}: JsonNodeViewProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    const isContainer = node.type === 'object' || node.type === 'array';
    const bracketOpen = node.type === 'object' ? '{' : '[';
    const bracketClose = node.type === 'object' ? '}' : ']';
    // expandedPaths 是父组件传下来的响应式 Set，随展开/折叠操作整体替换引用；
    // 必须用 track() 包裹才能在其变化时重新求值——顶层 const 只在组件首次
    // 挂载时计算一次，之后 expandedPaths 换了新引用也不会重新读取 .has()。
    let &[expanded] = track<boolean>(() => expandedPaths.has(node.path));
    let &[draftValue] = track<string>('');
    let &[isActiveMatch] = track<boolean>(() => activeMatchPath === node.path);
    // Escape/Enter 键盘处理后紧跟的浏览器原生 blur 事件不应该再重复提交
    // 一次——不是响应式状态，只是同一次编辑会话内的同步标记，随 input
    // 每次重新挂载（ref 回调触发）复位。
    let keyHandled = false;

    function scrollActiveIntoView(el: HTMLElement | null) {
        if (el && untrack(() => isActiveMatch)) el.scrollIntoView({ block: 'nearest' });
    }

    <>
    <li
        class={['lotus-json-viewer-node', isActiveMatch ? 'lotus-json-viewer-node-active-match' : ''].filter(Boolean).join(' ')}
        data-path={node.path}
        ref={isActiveMatch ? scrollActiveIntoView : undefined}
    >
        @if (isContainer) {
            <>
                <span
                    class={['lotus-json-viewer-switcher', expanded ? 'lotus-json-viewer-switcher-expanded' : ''].filter(Boolean).join(' ')}
                    role="button"
                    tabIndex={0}
                    aria-expanded={expanded}
                    aria-label={expanded ? locale.JsonViewer.collapseNode : locale.JsonViewer.expandNode}
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
                            {node.type === 'object' ? locale.JsonViewer.propertyCount(node.children.length) : locale.JsonViewer.itemCount(node.children.length)}
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
                                    editable={editable}
                                    editingPath={editingPath}
                                    onStartEdit={onStartEdit}
                                    onCommitEdit={onCommitEdit}
                                    onCancelEdit={onCancelEdit}
                                    activeMatchPath={activeMatchPath}
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
                @if (editable && editingPath === node.path) {
                    <input
                        type="text"
                        class="lotus-json-viewer-edit-input"
                        value={draftValue}
                        aria-label={locale.JsonViewer.editValue}
                        ref={(el: HTMLInputElement | null) => { if (el) { el.focus(); el.select(); keyHandled = false; } }}
                        onInput={(e: Event) => { draftValue = (e.target as HTMLInputElement).value; }}
                        onBlur={() => { if (!keyHandled) onCommitEdit?.(node.path, untrack(() => draftValue)); }}
                        onKeyDown={(e: KeyboardEvent) => {
                            if (e.key === 'Enter') {
                                e.preventDefault();
                                keyHandled = true;
                                onCommitEdit?.(node.path, untrack(() => draftValue));
                            } else if (e.key === 'Escape') {
                                e.preventDefault();
                                keyHandled = true;
                                onCancelEdit?.();
                            }
                        }}
                    />
                }
                @if (!(editable && editingPath === node.path)) {
                    <span
                        class={[valueClassName(node), editable ? 'lotus-json-viewer-value-editable' : ''].filter(Boolean).join(' ')}
                        role={editable ? 'button' : undefined}
                        tabIndex={editable ? 0 : undefined}
                        aria-label={editable ? locale.JsonViewer.editValue : undefined}
                        onClick={() => { if (editable) { draftValue = formatEditableValue(node); onStartEdit?.(node.path); } }}
                        onKeyDown={(e: KeyboardEvent) => {
                            if (editable && (e.key === 'Enter' || e.key === ' ')) {
                                e.preventDefault();
                                draftValue = formatEditableValue(node);
                                onStartEdit?.(node.path);
                            }
                        }}
                    >
                        {formatLeafValue(node)}
                    </span>
                }
            </>
        }
        @if (!isLast) {
            <span class="lotus-json-viewer-comma">,</span>
        }
    </li>
    </>
}
