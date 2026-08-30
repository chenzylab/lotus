import { Cascader, type CascaderNodeData } from '@lotus/ripple';

const REGION_DATA: CascaderNodeData[] = [
    {
        value: 'zhejiang',
        label: '浙江',
        children: [
            { value: 'hangzhou', label: '杭州', children: [{ value: 'xihu', label: '西湖区' }] },
            { value: 'ningbo', label: '宁波', children: [{ value: 'yinzhou', label: '鄞州区' }] },
        ],
    },
    { value: 'shanghai', label: '上海', children: [{ value: 'pudong', label: '浦东新区' }] },
];

export function CascaderMultipleDemo() @{
    <div style={{ width: '320px' }}>
        <Cascader
            treeData={REGION_DATA}
            multiple
            showClear
            placeholder="请选择多个地区"
            aria-label="多选级联选择"
        />
    </div>
}
