import { track } from 'ripple';
import { Tree, type TreeNodeData } from '@lotus/ripple';

const treeData: TreeNodeData[] = [
    { key: 'drag-1', label: '节点 1' },
    { key: 'drag-2', label: '节点 2' },
    { key: 'drag-3', label: '节点 3' },
];

export function DragTreeDemo() @{
    let &[log] = track<string>('');

    <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
        <Tree
            treeData={treeData}
            draggable
            onDrop={(info) => { log = `拖拽 ${info.dragNode?.label} 到 ${info.node.label}（dropToGap=${info.dropToGap}）`; }}
            aria-label="draggable 示例"
        />
        <div>日志：{log}</div>
    </div>
}
