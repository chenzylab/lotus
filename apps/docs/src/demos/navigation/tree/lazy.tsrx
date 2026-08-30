import { Tree, type TreeNodeData } from '@lotus/ripple';

function loadTreeChildren(node: TreeNodeData): Promise<TreeNodeData[]> {
    return new Promise((resolve) => {
        setTimeout(() => {
            resolve([
                { key: `${node.key}-c1`, label: `${node.label} 子节点 1` },
                { key: `${node.key}-c2`, label: `${node.label} 子节点 2`, isLeaf: false },
            ]);
        }, 600);
    });
}

export function LazyTreeDemo() @{
    <Tree
        treeData={[
            { key: 'lazy-1', label: '懒加载节点 1' },
            { key: 'lazy-2', label: '懒加载节点 2' },
        ]}
        loadData={loadTreeChildren}
        aria-label="懒加载 Tree"
    />
}
