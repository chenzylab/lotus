import type { FileContentItem } from '@lotus/foundation/show/sidebar';
import { Collapse } from '../collapse/index.tsrx';
import { CollapsePanel } from '../collapse/panel.tsrx';
import { FileItem } from './file-item.tsrx';

export type { FileContentItem };

export interface FileContentProps {
    files?: FileContentItem[];
    activeKey?: string | string[];
    onChange?: (activeKey: string[]) => void;
    onExpand?: (event: MouseEvent, file: FileContentItem, mode: 'file') => void;
    class?: string;
    style?: Record<string, any>;
}

/**
 * Sidebar.FileContent：多个文件的可折叠预览列表，与 CodeContent 同一
 * Collapse 容器模式。列表内 FileItem 硬编码 `editable={false}`（对齐 Semi
 * 源码行为——列表预览态全部只读，只有 Sidebar 详情视图单独渲染的 FileItem
 * 才吃 `fileEditable`）。
 */
export function FileContent(&{ files, activeKey, onChange, onExpand, class: className, style }: FileContentProps) @{
    function handleChange(keys: string[], event: MouseEvent) {
        onChange?.(keys);
        const expandedKey = keys[keys.length - 1];
        const item = (files ?? []).find((f) => f.key === expandedKey);
        if (item && expandedKey && keys.includes(expandedKey)) {
            onExpand?.(event, item, 'file');
        }
    }

    <>
        <div class={['lotus-sidebar-file-content', className ?? ''].filter(Boolean).join(' ')} style={style}>
            <Collapse activeKey={activeKey} onChange={handleChange}>
                @for (const item of files ?? []; key item.key) {
                    <CollapsePanel itemKey={item.key} header={item.name ?? item.key}>
                        <FileItem content={item.content} editable={false} />
                    </CollapsePanel>
                }
            </Collapse>
        </div>

        <style>
            .lotus-sidebar-file-content {
                display: flex;
                flex-direction: column;
            }
        </style>
    </>
}
