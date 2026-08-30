import { Tree, type TreeNodeData } from '@lotus/ripple';

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
            {
                key: 'dept-1-2',
                label: '后端组',
                children: [
                    { key: 'dept-1-2-1', label: '王五' },
                    { key: 'dept-1-2-2', label: '赵六', disabled: true },
                ],
            },
        ],
    },
    {
        key: 'dept-2',
        label: '产品部',
        children: [
            { key: 'dept-2-1', label: '刘七' },
            { key: 'dept-2-2', label: '陈八' },
        ],
    },
];

export function MultipleTreeDemo() @{
    <Tree
        treeData={treeData}
        multiple
        defaultExpandAll
        aria-label="多选 Tree（三态级联）"
    />
}
