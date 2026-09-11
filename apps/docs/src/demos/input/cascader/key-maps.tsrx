import { Cascader } from '@lotus/ripple';

const DATA = [
    { val: 'zhejiang', name: '浙江', items: [{ val: 'hangzhou', name: '杭州' }, { val: 'ningbo', name: '宁波' }] },
    { val: 'jiangsu', name: '江苏', items: [{ val: 'nanjing', name: '南京' }] },
];

export function KeyMapsCascaderDemo() @{
    <Cascader treeData={DATA} keyMaps={{ value: 'val', label: 'name', children: 'items' }} />
}
