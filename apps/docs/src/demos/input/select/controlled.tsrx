import { track } from 'ripple';
import { Select, Button, Space } from '@lotus/ripple';
import type { SelectOptionData } from '@lotus/ripple';

const options: SelectOptionData[] = [
    { value: 'douyin', label: '抖音' },
    { value: 'xigua', label: '西瓜视频' },
];

export function SelectControlledDemo() @{
    let &[value] = track<string>('douyin');

    <Space>
        <Select
            optionList={options}
            value={value}
            onChange={(next) => { if (typeof next === 'string') value = next; }}
            aria-label="受控示例"
        />
        <Button onClick={() => { value = value === 'douyin' ? 'xigua' : 'douyin'; }}>切换</Button>
    </Space>
}
