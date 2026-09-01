import { Transfer, Checkbox, Button } from '@lotus/ripple';

const dataSource = [
    { key: 'a1', label: '苹果' },
    { key: 'a2', label: '香蕉' },
    { key: 'a3', label: '樱桃' },
];

export function RenderCustomTransferDemo() @{
    <Transfer
        dataSource={dataSource}
        draggable
        renderSourceItem={(item) => (
            <div onClick={item.onChange} style={{ display: 'flex', alignItems: 'center', gap: '6px', cursor: 'pointer' }}>
                <Checkbox checked={item.checked} aria-label={`自定义源项 ${item.label}`} />
                <span>★ {item.label}</span>
            </div>
        )}
        renderSelectedItem={(item) => (
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', width: '100%' }}>
                <span role="button" aria-label={`拖拽手柄 ${item.label}`} onMouseDown={item.dragHandleOnMouseDown} style={{ cursor: 'grab' }}>☰</span>
                <span style={{ flex: '1' }}>◆ {item.label}</span>
                <Button size="small" theme="borderless" onClick={item.onRemove} aria-label={`移除 ${item.label}`}>移除</Button>
            </div>
        )}
        aria-label="Transfer renderItem 自定义示例"
    />
}
