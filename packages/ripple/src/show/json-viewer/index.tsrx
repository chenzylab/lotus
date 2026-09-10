import { track, untrack } from 'ripple';
import {
    JsonViewerFoundation,
    parseToJsonTree,
    calcDefaultExpandedPaths,
    calcAllExpandedPaths,
    parseLeafEditInput,
    findNodeByPath,
    searchJsonTree,
    calcSearchExpandPaths,
    type JsonViewerState,
    type JsonNode,
} from '@lotus/foundation/show/json-viewer';
import { Input } from '../../input/input/index.tsrx';
import { IconSearch, IconChevronUp, IconChevronDown } from '@lotus/icons';
import { CopyableAction } from '../../basic/typography/shared.tsrx';
import { JsonNodeView } from './json-node-view.tsrx';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export interface JsonViewerProps {
    /** 待展示的 JSON 数据：可以是已解析的对象/数组/原始值，也可以是 JSON 字符串。 */
    value?: unknown;
    /** 默认展开层级，0 表示全部折叠，Infinity 表示全部展开。默认 1（只展开根节点）。 */
    defaultExpandDepth?: number;
    /** 是否显示复制按钮（复制格式化后的完整 JSON 文本）。默认 true。 */
    showCopy?: boolean;
    /** 叶子节点是否可原地编辑（点击值区域进入编辑态，Enter/失焦提交，Esc 取消）。
     * lotus 是结构化树查看器定位（非 Semi 那种基于 Monaco 的完整代码编辑器），
     * 编辑粒度是"单个叶子值原地替换"而不是整段 JSON 文本重新解析。默认 false。 */
    editable?: boolean;
    /** 叶子节点编辑提交后触发，携带还原成普通 JS 值的完整结果。 */
    onChange?: (value: unknown) => void;
    /** 是否显示搜索框：搜索 key（对象成员名）或叶子展示值，命中路径自动
     * 展开祖先、当前命中高亮，支持上一个/下一个跳转。lotus 树形展示架构
     * 下的搜索定位（不是 Semi 那种 Monaco 编辑器内置的文本搜索替换）。 */
    showSearch?: boolean;
    /** 容器宽度，超出时横向滚动。 */
    width?: number | string;
    /** 容器高度，超出时纵向滚动。 */
    height?: number | string;
    class?: string;
    style?: Record<string, any>;
    'aria-label'?: string;
}

export function JsonViewer(&{
    value,
    defaultExpandDepth = 1,
    showCopy = true,
    editable = false,
    onChange,
    showSearch = false,
    width,
    height,
    class: className,
    style,
    'aria-label': ariaLabel,
}: JsonViewerProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    let &[root] = track<JsonNode | null>(() => parseToJsonTree(value));
    let &[state] = track<JsonViewerState>(() => ({
        expandedPaths: root ? calcDefaultExpandedPaths(root, defaultExpandDepth) : new Set<string>(),
    }));
    let &[editingPath] = track<string | null>(null);

    let &[searchQuery] = track<string>('');
    let &[searchActiveIndex] = track<number>(0);
    let &[searchMatches] = track<string[]>(() => (root && searchQuery ? searchJsonTree(root, searchQuery) : []));
    let &[activeMatchPath] = track<string | null>(() => searchMatches[searchActiveIndex] ?? null);

    function handleSearchInput(next: string) {
        searchQuery = next;
        searchActiveIndex = 0;
        expandToActiveMatch();
    }

    function expandToActiveMatch() {
        const matches = untrack(() => searchMatches);
        const index = untrack(() => searchActiveIndex);
        const path = matches[index];
        if (!path) return;
        const expandPaths = calcSearchExpandPaths([path]);
        const current = untrack(() => state).expandedPaths;
        const next = new Set(current);
        for (const p of expandPaths) next.add(p);
        state = { ...untrack(() => state), expandedPaths: next };
    }

    function handleSearchPrev() {
        const total = untrack(() => searchMatches).length;
        if (total === 0) return;
        searchActiveIndex = (untrack(() => searchActiveIndex) - 1 + total) % total;
        expandToActiveMatch();
    }

    function handleSearchNext() {
        const total = untrack(() => searchMatches).length;
        if (total === 0) return;
        searchActiveIndex = (untrack(() => searchActiveIndex) + 1) % total;
        expandToActiveMatch();
    }

    const foundation = new JsonViewerFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<JsonViewerState>) => { state = { ...untrack(() => state), ...patch }; },
    });

    function handleToggleExpand(path: string) {
        foundation.handleToggleExpand(path);
    }

    function handleExpandAll() {
        const currentRoot = untrack(() => root);
        if (!currentRoot) return;
        state = { ...untrack(() => state), expandedPaths: calcAllExpandedPaths(currentRoot) };
    }

    function handleCollapseAll() {
        state = { ...untrack(() => state), expandedPaths: new Set() };
    }

    // 可编辑模式是受控的：提交编辑只计算出替换后的新值并调用 onChange，
    // 不在组件内部维护一份独立于 value prop 的树副本——树的显示始终以
    // value 为准，外部把 onChange 回传的新值原样传回 value 才会看到编辑
    // 生效，这跟 Semi JsonViewer 本身也需要外部配合回传新 value 驱动
    // Monaco 内容更新是同样的受控语义，不引入"内部状态和外部 prop 谁
    // 说了算"的歧义。
    function handleStartEdit(path: string) {
        editingPath = path;
    }

    function handleCancelEdit() {
        editingPath = null;
    }

    function handleCommitEdit(path: string, rawInput: string) {
        editingPath = null;
        const currentRoot = untrack(() => root);
        if (!currentRoot) return;
        const node = findNodeByPath(currentRoot, path);
        if (!node) return;
        const nextLeafValue = parseLeafEditInput(rawInput, node.type);
        const result = foundation.handleEditCommit(currentRoot, path, nextLeafValue);
        onChange?.(result.value);
    }

    let &[copyText] = track<string>(() => JSON.stringify(value, null, 2));

    <>
        <div
            class={['lotus-json-viewer', className ?? ''].filter(Boolean).join(' ')}
            style={{
                ...(width !== undefined ? { width: typeof width === 'number' ? `${width}px` : width } : {}),
                ...(height !== undefined ? { height: typeof height === 'number' ? `${height}px` : height, overflow: 'auto' } : {}),
                ...style,
            }}
            aria-label={ariaLabel}
        >
            <div class="lotus-json-viewer-toolbar">
                <button type="button" class="lotus-json-viewer-toolbar-btn" onClick={handleExpandAll}>{locale.JsonViewer.expandAll}</button>
                <button type="button" class="lotus-json-viewer-toolbar-btn" onClick={handleCollapseAll}>{locale.JsonViewer.collapseAll}</button>
                @if (showCopy) {
                    <CopyableAction config={{}} textContent={copyText} />
                }
            </div>
            @if (showSearch) {
                <div class="lotus-json-viewer-search">
                    <Input
                        value={searchQuery}
                        onChange={handleSearchInput}
                        placeholder={locale.JsonViewer.searchPlaceholder}
                        prefix={<IconSearch />}
                        size="small"
                        showClear
                        aria-label={locale.JsonViewer.searchPlaceholder}
                    />
                    @if (searchQuery !== '') {
                        <>
                            <span class="lotus-json-viewer-search-count">
                                {searchMatches.length > 0 ? locale.JsonViewer.searchResultCount(searchActiveIndex + 1, searchMatches.length) : locale.JsonViewer.noSearchResult}
                            </span>
                            <button
                                type="button"
                                class="lotus-json-viewer-search-btn"
                                aria-label={locale.JsonViewer.searchPrev}
                                disabled={searchMatches.length === 0}
                                onClick={handleSearchPrev}
                            >
                                <IconChevronUp />
                            </button>
                            <button
                                type="button"
                                class="lotus-json-viewer-search-btn"
                                aria-label={locale.JsonViewer.searchNext}
                                disabled={searchMatches.length === 0}
                                onClick={handleSearchNext}
                            >
                                <IconChevronDown />
                            </button>
                        </>
                    }
                </div>
            }
            @if (root) {
                <ul class="lotus-json-viewer-root">
                    <JsonNodeView
                        node={root}
                        expandedPaths={state.expandedPaths}
                        onToggleExpand={handleToggleExpand}
                        isLast={true}
                        editable={editable}
                        editingPath={editingPath}
                        onStartEdit={handleStartEdit}
                        onCommitEdit={handleCommitEdit}
                        onCancelEdit={handleCancelEdit}
                        activeMatchPath={activeMatchPath}
                    />
                </ul>
            } @else {
                <div class="lotus-json-viewer-invalid">{locale.JsonViewer.invalidData}</div>
            }
        </div>

        <style>
            .lotus-json-viewer {
                font-family: ui-monospace, 'SFMono-Regular', 'SF Mono', Menlo, Monaco, Consolas, 'Liberation Mono', 'DejaVu Sans Mono', 'Courier New', monospace;
                font-size: 13px;
                line-height: 1.6;
                color: var(--lotus-color-text-0);
            }

            .lotus-json-viewer-toolbar {
                display: flex;
                align-items: center;
                gap: 8px;
                margin-bottom: 8px;
            }

            .lotus-json-viewer-toolbar-btn {
                border: 1px solid var(--lotus-color-border);
                background: var(--lotus-color-bg-0);
                color: var(--lotus-color-text-1);
                border-radius: var(--lotus-border-radius-small);
                padding: 2px 8px;
                font-size: 12px;
                cursor: pointer;
            }

            .lotus-json-viewer-toolbar-btn:hover {
                border-color: var(--lotus-color-primary);
                color: var(--lotus-color-primary);
            }

            .lotus-json-viewer-invalid {
                color: var(--lotus-color-danger);
            }

            .lotus-json-viewer :global(.lotus-json-viewer-root),
            .lotus-json-viewer :global(.lotus-json-viewer-children) {
                list-style: none;
                margin: 0;
                padding-inline-start: 1.4em;
            }

            .lotus-json-viewer :global(.lotus-json-viewer-root) {
                padding-inline-start: 0;
            }

            .lotus-json-viewer :global(.lotus-json-viewer-node) {
                position: relative;
            }

            .lotus-json-viewer :global(.lotus-json-viewer-switcher) {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                width: 1em;
                height: 1em;
                margin-inline-end: 2px;
                cursor: pointer;
                transition: transform 0.15s;
                color: var(--lotus-color-text-2);
                vertical-align: -0.15em;
            }

            .lotus-json-viewer :global(.lotus-json-viewer-switcher-expanded) {
                transform: rotate(90deg);
            }

            .lotus-json-viewer :global(.lotus-json-viewer-switcher-placeholder) {
                cursor: default;
            }

            .lotus-json-viewer :global(.lotus-json-viewer-key) {
                color: var(--lotus-color-danger);
            }

            .lotus-json-viewer :global(.lotus-json-viewer-colon) {
                margin-inline-end: 0.4em;
                color: var(--lotus-color-text-2);
            }

            .lotus-json-viewer :global(.lotus-json-viewer-bracket) {
                color: var(--lotus-color-text-2);
            }

            .lotus-json-viewer :global(.lotus-json-viewer-comma) {
                color: var(--lotus-color-text-2);
            }

            .lotus-json-viewer :global(.lotus-json-viewer-collapsed-summary) {
                margin: 0 0.4em;
                color: var(--lotus-color-text-3);
                font-style: italic;
            }

            .lotus-json-viewer :global(.lotus-json-viewer-value-string) {
                color: #2f9e44;
            }

            .lotus-json-viewer :global(.lotus-json-viewer-value-number) {
                color: #7048e8;
            }

            .lotus-json-viewer :global(.lotus-json-viewer-value-boolean) {
                color: #895fe2;
            }

            .lotus-json-viewer :global(.lotus-json-viewer-value-null) {
                color: var(--lotus-color-text-3);
            }

            .lotus-json-viewer :global(.lotus-json-viewer-value-editable) {
                cursor: pointer;
                border-radius: 2px;
                padding: 0 2px;
                margin: 0 -2px;
            }

            .lotus-json-viewer :global(.lotus-json-viewer-value-editable:hover) {
                background: var(--lotus-color-fill-0);
                outline: 1px dashed var(--lotus-color-border);
            }

            .lotus-json-viewer :global(.lotus-json-viewer-node-active-match) {
                background: var(--lotus-color-warning-light-default);
                outline: 1px solid var(--lotus-color-warning);
                border-radius: 2px;
            }

            .lotus-json-viewer-search {
                display: flex;
                align-items: center;
                gap: 6px;
                margin-bottom: 8px;
            }

            .lotus-json-viewer-search-count {
                font-size: 12px;
                color: var(--lotus-color-text-2);
                white-space: nowrap;
            }

            .lotus-json-viewer-search-btn {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                border: 1px solid var(--lotus-color-border);
                background: var(--lotus-color-bg-0);
                color: var(--lotus-color-text-1);
                border-radius: var(--lotus-border-radius-small);
                width: 24px;
                height: 24px;
                cursor: pointer;
            }

            .lotus-json-viewer-search-btn:hover {
                border-color: var(--lotus-color-primary);
                color: var(--lotus-color-primary);
            }

            .lotus-json-viewer-search-btn:disabled {
                cursor: not-allowed;
                opacity: 0.5;
            }

            .lotus-json-viewer :global(.lotus-json-viewer-edit-input) {
                font-family: inherit;
                font-size: inherit;
                line-height: inherit;
                border: 1px solid var(--lotus-color-primary);
                border-radius: 2px;
                padding: 0 2px;
                margin: 0 -3px;
                background: var(--lotus-color-bg-1);
                color: var(--lotus-color-text-0);
                min-width: 40px;
            }
        </style>
    </>
}
