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
            { key: 'dept-1-2', label: '后端组', children: [{ key: 'dept-1-2-1', label: '王五' }] },
        ],
    },
    { key: 'dept-2', label: '产品部', children: [{ key: 'dept-2-1', label: '刘七' }] },
];

export function MultipleTreeSelectDemo() {
    return (
        <div style={{ width: '320px' }}>
            <TreeSelect
                treeData={treeData}
                multiple
                showClear
                maxTagCount={2}
                placeholder="请选择部门/员工"
                aria-label="TreeSelect 多选"
            />
        </div>
    );
}
