import { Resizable } from '@lotus/ripple';

export function BasicResizableDemo() {
    return <Resizable
        defaultWidth={240}
        defaultHeight={120}
        minWidth={120}
        minHeight={80}
        maxWidth={480}
        maxHeight={320}
        aria-label="可调整大小容器"
    >
        <div style={{ padding: '12px' }}>拖拽边缘或角落调整大小（也可 Tab 聚焦手柄后用方向键调整）</div>
    </Resizable>;
}
