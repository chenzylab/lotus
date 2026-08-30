import { track } from 'ripple';
import { Transfer } from '@lotus/ripple';

const dataSource = [
    { title: '水果', children: [{ key: 'g1', label: '苹果' }, { key: 'g2', label: '香蕉' }] },
    { title: '蔬菜', children: [{ key: 'g3', label: '西红柿' }, { key: 'g4', label: '黄瓜', disabled: true }] },
];

export function GroupTransferDemo() @{
    let &[value] = track<Array<string | number>>([]);

    <Transfer
        type="groupList"
        dataSource={dataSource}
        value={value}
        onChange={(v) => { value = v; }}
        aria-label="Transfer 分组"
    />
}
