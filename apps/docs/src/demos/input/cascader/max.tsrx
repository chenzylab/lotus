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

export function CascaderMaxDemo() @{
    <div style={{ width: '320px' }}>
        <Cascader
            treeData={REGION_DATA}
            multiple
            clickToSelect
            leafOnly
            max={2}
            placeholder="最多选 2 个叶子节点"
            onExceed={() => console.log('已达上限')}
        />
    </div>
}
