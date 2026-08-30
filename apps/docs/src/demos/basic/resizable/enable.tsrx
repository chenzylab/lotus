import { Resizable } from '@lotus/ripple';

export function EnableResizableDemo() {
    return <Resizable
        defaultWidth={240}
        defaultHeight={100}
        minWidth={120}
        minHeight={60}
        enable={['right', 'bottom', 'bottomRight']}
        aria-label="仅右/下/右下方向可调整大小的容器"
    >
        <div style={{ padding: '12px' }}>只启用右、下、右下三个方向的手柄</div>
    </Resizable>;
}
