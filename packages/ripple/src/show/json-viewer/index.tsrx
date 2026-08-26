import { track, untrack } from 'ripple';
import {
    JsonViewerFoundation,
    parseToJsonTree,
    calcDefaultExpandedPaths,
    calcAllExpandedPaths,
    type JsonViewerState,
    type JsonNode,
} from '@lotus/foundation/show/json-viewer';
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
    class?: string;
    style?: Record<string, any>;
}

export function JsonViewer(&{
    value,
    defaultExpandDepth = 1,
    showCopy = true,
    class: className,
    style,
}: JsonViewerProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    let &[root] = track<JsonNode | null>(() => parseToJsonTree(value));
    let &[state] = track<JsonViewerState>(() => ({
        expandedPaths: root ? calcDefaultExpandedPaths(root, defaultExpandDepth) : new Set<string>(),
    }));

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

    let &[copyText] = track<string>(() => JSON.stringify(value, null, 2));

    <>
        <div class={['lotus-json-viewer', className ?? ''].filter(Boolean).join(' ')} style={style}>
            <div class="lotus-json-viewer-toolbar">
                <button type="button" class="lotus-json-viewer-toolbar-btn" onClick={handleExpandAll}>{locale.JsonViewer.expandAll}</button>
                <button type="button" class="lotus-json-viewer-toolbar-btn" onClick={handleCollapseAll}>{locale.JsonViewer.collapseAll}</button>
                @if (showCopy) {
                    <CopyableAction config={{}} textContent={copyText} />
                }
            </div>
            @if (root) {
                <ul class="lotus-json-viewer-root">
                    <JsonNodeView node={root} expandedPaths={state.expandedPaths} onToggleExpand={handleToggleExpand} isLast={true} />
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
                padding-left: 1.4em;
            }

            .lotus-json-viewer :global(.lotus-json-viewer-root) {
                padding-left: 0;
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
                margin-right: 2px;
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
                margin-right: 0.4em;
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
        </style>
    </>
}
