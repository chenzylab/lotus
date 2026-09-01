import { Cascader, type CascaderNodeData } from '@lotus/ripple';

const REGION_DATA: CascaderNodeData[] = [
    {
        value: 'zhejiang',
        label: '浙江',
        children: [
            { value: 'hangzhou', label: '杭州', children: [{ value: 'xihu', label: '西湖区' }, { value: 'binjiang', label: '滨江区' }] },
            { value: 'ningbo', label: '宁波', children: [{ value: 'yinzhou', label: '鄞州区' }] },
        ],
    },
];

export function CascaderMaxTagCountDemo() @{
    <div style={{ width: '320px' }}>
        <Cascader
            treeData={REGION_DATA}
            multiple
            clickToSelect
            leafOnly
            maxTagCount={2}
            defaultValue={[['zhejiang', 'hangzhou', 'xihu'], ['zhejiang', 'hangzhou', 'binjiang'], ['zhejiang', 'ningbo', 'yinzhou']]}
        />
    </div>
}
