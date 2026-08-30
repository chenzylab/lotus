import { Cascader, type CascaderNodeData } from '@lotus/ripple';

const REGION_DATA: CascaderNodeData[] = [
    {
        value: 'zhejiang',
        label: '浙江',
        children: [
            { value: 'hangzhou', label: '杭州', children: [{ value: 'xihu', label: '西湖区' }] },
        ],
    },
    { value: 'jiangsu', label: '江苏', children: [{ value: 'nanjing', label: '南京', children: [{ value: 'xuanwu', label: '玄武区' }] }] },
];

export function CascaderSearchDemo() @{
    <div style={{ width: '280px' }}>
        <Cascader
            treeData={REGION_DATA}
            filterTreeNode
            searchPlaceholder="搜索地区"
            placeholder="请选择省市区"
            aria-label="可搜索级联选择"
        />
    </div>
}
