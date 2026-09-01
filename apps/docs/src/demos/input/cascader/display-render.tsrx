import { Cascader, type CascaderNodeData } from '@lotus/ripple';

const REGION_DATA: CascaderNodeData[] = [
    { value: 'zhejiang', label: '浙江', children: [{ value: 'hangzhou', label: '杭州', children: [{ value: 'xihu', label: '西湖区' }] }] },
];

export function CascaderDisplayRenderDemo() @{
    <div style={{ width: '280px' }}>
        <Cascader
            treeData={REGION_DATA}
            defaultValue={['zhejiang', 'hangzhou', 'xihu']}
            displayRender={(pathLabel) => `已选：${pathLabel}`}
        />
    </div>
}
