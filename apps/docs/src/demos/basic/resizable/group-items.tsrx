import { ResizeGroup } from '@lotus/ripple';

export function GroupItemsResizableDemo() {
    return <div style={{ width: '100%', height: '80px' }}>
        <ResizeGroup
            direction="horizontal"
            aria-label="分栏面板（items 简化写法）"
            items={[
                { content: <div style={{ padding: '8px' }}>items 面板一</div>, defaultSize: '200px', style: { background: 'rgba(0,0,0,0.04)' } },
                { content: <div style={{ padding: '8px' }}>items 面板二</div>, defaultSize: 1, style: { background: 'rgba(0,0,0,0.08)' } },
            ]}
        />
    </div>;
}
