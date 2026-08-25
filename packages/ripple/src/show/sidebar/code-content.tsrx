import { resolveCodeItemViewer, type CodeItem } from '@lotus/foundation/show/sidebar';
import { Collapse } from '../collapse/index.tsrx';
import { CollapsePanel } from '../collapse/panel.tsrx';
import { CodeHighlight } from '../code-highlight/index.tsrx';
import { JsonViewer } from '../json-viewer/index.tsrx';

export type { CodeItem };

export interface CodeContentProps {
    codes?: CodeItem[];
    activeKey?: string | string[];
    onChange?: (activeKey: string[]) => void;
    onExpand?: (event: MouseEvent, code: CodeItem, mode: 'code') => void;
    class?: string;
    style?: Record<string, any>;
}

/**
 * Sidebar.CodeContent：多个代码/JSON 块的可折叠列表，直接复用已有 Collapse
 * 承载分组折叠语义（对齐 Semi 自身也是用 Collapse 包一层的实现），单个块按
 * isJson 分流到 JsonViewer（结构化查看，天然只读）或 CodeHighlight（语法高亮）。
 */
export function CodeContent(&{ codes, activeKey, onChange, onExpand, class: className, style }: CodeContentProps) @{
    function handleChange(keys: string[], event: MouseEvent) {
        onChange?.(keys);
        const expandedKey = keys[keys.length - 1];
        const item = (codes ?? []).find((c) => c.key === expandedKey);
        if (item && expandedKey && keys.includes(expandedKey)) {
            onExpand?.(event, item, 'code');
        }
    }

    <>
        <div class={['lotus-sidebar-code-content', className ?? ''].filter(Boolean).join(' ')} style={style}>
            <Collapse activeKey={activeKey} onChange={handleChange}>
                @for (const item of codes ?? []; key item.key) {
                    <CollapsePanel itemKey={item.key} header={item.name ?? item.key}>
                        @if (resolveCodeItemViewer(item) === 'json') {
                            <JsonViewer value={item.content} {...(item.jsonViewerProps ?? {})} />
                        } @else {
                            <CodeHighlight code={item.content} language={item.language} {...(item.codeHighlightProps ?? {})} />
                        }
                    </CollapsePanel>
                }
            </Collapse>
        </div>

        <style>
            .lotus-sidebar-code-content {
                display: flex;
                flex-direction: column;
            }
        </style>
    </>
}
