import { TreeSelect, type TreeNodeData } from '@lotus/ripple';

const treeData: TreeNodeData[] = [
    {
        key: 'dept-1',
        label: '研发部',
        children: [
            {
                key: 'dept-1-1',
                label: '前端组',
                children: [
                    { key: 'dept-1-1-1', label: '张三' },
                    { key: 'dept-1-1-2', label: '李四' },
                ],
            },
        ],
    },
    { key: 'dept-2', label: '产品部', children: [{ key: 'dept-2-1', label: '刘七' }] },
];

export function SearchTreeSelectDemo() {
    return (
        <div style={{ width: '280px' }}>
            <TreeSelect
                treeData={treeData}
                filterTreeNode
                searchPlaceholder="搜索姓名/部门"
                placeholder="请选择员工"
                aria-label="TreeSelect 搜索"
            />
        </div>
    );
}
