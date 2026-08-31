import { Resizable } from '@lotus/ripple';

export function ConstraintsResizableDemo() {
    return <div style={{ width: '300px', height: '200px', border: '1px solid var(--lotus-color-border)', position: 'relative' }}>
        <Resizable
            defaultWidth={150}
            defaultHeight={100}
            boundElement="parent"
            grid={[20, 20]}
            handleStyle={{ bottomRight: { background: 'var(--lotus-color-primary)' } }}
            aria-label="限制在父容器内、20px 网格吸附的可调整大小容器"
        >
            <div style={{ padding: '8px' }}>boundElement="parent"，grid=[20,20]</div>
        </Resizable>
    </div>;
}
