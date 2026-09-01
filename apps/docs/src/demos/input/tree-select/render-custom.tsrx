import { Button, Tag, TreeSelect, type TreeNodeData } from '@lotus/ripple';

const treeData: TreeNodeData[] = [
    {
        key: 'dept-1',
        label: '研发部',
        children: [
            { key: 'dept-1-1', label: '张三' },
            { key: 'dept-1-2', label: '李四' },
        ],
    },
    { key: 'dept-2', label: '产品部', children: [{ key: 'dept-2-1', label: '王五' }] },
];

export function RenderCustomTreeSelectDemo() {
    return (
        <div style={{ width: '280px', display: 'flex', flexDirection: 'column', gap: '12px' }}>
            <TreeSelect
                treeData={treeData}
                placeholder="请选择员工"
                triggerRender={({ value, placeholder, open }) => (
                    <Button aria-label="TreeSelect triggerRender 示例">
                        {(value as string) || placeholder}（{open ? '展开' : '收起'}）
                    </Button>
                )}
            />
            <TreeSelect
                treeData={treeData}
                multiple
                defaultValue={['dept-1-1', 'dept-1-2']}
                renderSelectedItem={(node, { onClose }) => (
                    <Tag color="orange" onClose={onClose} closable>{`★ ${node.label}`}</Tag>
                )}
            />
        </div>
    );
}
