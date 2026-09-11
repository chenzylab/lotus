import { Tree } from '@lotus/ripple';

const DATA = [
    { id: 'dept-1', name: '研发部', items: [{ id: 'dept-1-1', name: '前端组' }, { id: 'dept-1-2', name: '后端组' }] },
    { id: 'dept-2', name: '产品部', items: [{ id: 'dept-2-1', name: '刘七' }] },
];

export function KeyMapsTreeDemo() @{
    <Tree
        treeData={DATA}
        keyMaps={{ key: 'id', label: 'name', children: 'items' }}
        defaultExpandAll
    />
}
