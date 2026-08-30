import { DragMove } from '@lotus/ripple';

export function BasicDragMoveDemo() {
    return <DragMove>
        <div style={{
            width: '80px',
            height: '80px',
            background: 'var(--lotus-color-primary)',
            color: '#fff',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            borderRadius: 'var(--lotus-border-radius-medium)',
            userSelect: 'none',
        }}>
            拖我
        </div>
    </DragMove>;
}
