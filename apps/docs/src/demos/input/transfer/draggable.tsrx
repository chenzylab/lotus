import { Transfer } from '@lotus/ripple';

const dataSource = [
    { key: 'a1', label: '苹果' },
    { key: 'a2', label: '香蕉' },
    { key: 'a3', label: '樱桃' },
    { key: 'a4', label: '榴莲' },
];

export function DraggableTransferDemo() {
    return <Transfer dataSource={dataSource} draggable aria-label="Transfer 拖拽" />;
}
