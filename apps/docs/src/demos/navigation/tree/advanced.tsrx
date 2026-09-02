import { track } from 'ripple';
import { Tree, type TreeNodeData } from '@lotus/ripple';

const treeData: TreeNodeData[] = [
    {
        key: 'dept-1',
        label: '研发部',
        children: [
            { key: 'dept-1-1', label: '前端组', children: [{ key: 'dept-1-1-1', label: '张三' }, { key: 'dept-1-1-2', label: '李四' }] },
            { key: 'dept-1-2', label: '后端组', children: [{ key: 'dept-1-2-1', label: '王五' }, { key: 'dept-1-2-2', label: '赵六', disabled: true }] },
        ],
    },
    { key: 'dept-2', label: '产品部', children: [{ key: 'dept-2-1', label: '刘七' }, { key: 'dept-2-2', label: '陈八' }] },
];

export function AdvancedTreeDemo() @{
    let &[log] = track<string>('');

    <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
        <Tree
            treeData={treeData}
            multiple
            checkRelation="unRelated"
            defaultExpandAll
            onChange={(value) => { log = `checkRelation=unRelated：${JSON.stringify(value)}`; }}
            aria-label="checkRelation unRelated 示例"
        />
        <Tree
            treeData={treeData}
            directory
            expandAction="click"
            showLine
            defaultExpandedKeys={['dept-1']}
            onSelect={(key) => { log = `directory 选中：${key}`; }}
            aria-label="directory 示例"
        />
        <div>日志：{log}</div>
    </div>
}
