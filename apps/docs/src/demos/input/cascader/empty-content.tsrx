import { Cascader, type CascaderNodeData } from '@lotus/ripple';

const REGION_DATA: CascaderNodeData[] = [
    { value: 'zhejiang', label: '浙江', children: [{ value: 'hangzhou', label: '杭州' }] },
];

export function CascaderEmptyContentDemo() @{
    <div style={{ width: '280px' }}>
        <Cascader treeData={REGION_DATA} filterTreeNode emptyContent="没有找到匹配的地区" searchPlaceholder="搜索一个不存在的地区试试" />
    </div>
}
