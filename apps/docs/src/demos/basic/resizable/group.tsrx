import { ResizeGroup, ResizeItem, ResizeHandler } from '@lotus/ripple';

export function GroupResizableDemo() {
    return <div style={{ width: '100%', height: '80px' }}>
        <ResizeGroup direction="horizontal" aria-label="分栏面板">
            <ResizeItem defaultSize="30%" min="10%" style={{ background: 'rgba(0,0,0,0.04)' }}>
                <div style={{ padding: '8px' }}>面板一 30%</div>
            </ResizeItem>
            <ResizeHandler />
            <ResizeItem defaultSize={1} style={{ background: 'rgba(0,0,0,0.08)' }}>
                <div style={{ padding: '8px' }}>面板二 flex</div>
            </ResizeItem>
            <ResizeHandler />
            <ResizeItem defaultSize={1} style={{ background: 'rgba(0,0,0,0.04)' }}>
                <div style={{ padding: '8px' }}>面板三 flex</div>
            </ResizeItem>
        </ResizeGroup>
    </div>;
}
