import { track } from 'ripple';
import { Transfer } from '@lotus/ripple';

const dataSource = [
    { key: 'a1', label: '苹果' },
    { key: 'a2', label: '香蕉' },
    { key: 'a3', label: '樱桃' },
    { key: 'a4', label: '榴莲' },
    { key: 'a5', label: '芒果', disabled: true },
];

export function BasicTransferDemo() @{
    let &[value] = track<Array<string | number>>([]);

    <Transfer
        dataSource={dataSource}
        value={value}
        onChange={(v) => { value = v; }}
        aria-label="Transfer 基础"
    />
}
