import { track } from 'ripple';
import { TreeSelect, TypographyText, type TreeNodeData } from '@lotus/ripple';

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

export function BasicTreeSelectDemo() @{
    let &[log] = track<string>('');

    <div style={{ width: '280px' }}>
        <TreeSelect
            treeData={treeData}
            placeholder="请选择员工"
            onChange={(v) => { log = `onChange: ${JSON.stringify(v)}`; }}
            aria-label="TreeSelect 单选"
        />
        <TypographyText type="secondary" aria-label="TreeSelect 事件日志">{log}</TypographyText>
    </div>
}
