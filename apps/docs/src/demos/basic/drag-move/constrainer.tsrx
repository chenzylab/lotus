import { DragMove } from '@lotus/ripple';

export function ConstrainerDragMoveDemo() {
    return <div style={{
        position: 'relative',
        width: '320px',
        height: '200px',
        border: '1px solid var(--lotus-color-border)',
        overflow: 'hidden',
    }}>
        <DragMove constrainer="parent">
            <div style={{
                width: '80px',
                height: '80px',
                background: 'var(--lotus-color-success)',
                color: '#fff',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                borderRadius: 'var(--lotus-border-radius-medium)',
                userSelect: 'none',
            }}>
                拖我
            </div>
        </DragMove>
    </div>;
}
