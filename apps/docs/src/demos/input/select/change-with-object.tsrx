import { Select } from '@lotus/ripple';
import type { SelectOptionData } from '@lotus/ripple';

const options: SelectOptionData[] = [
    { value: 'douyin', label: '抖音' },
    { value: 'ulikecam', label: '轻颜相机' },
    { value: 'jianying', label: '剪映' },
    { value: 'xigua', label: '西瓜视频' },
];

export function SelectChangeWithObjectDemo() {
    return (
        <Select
            optionList={options}
            onChangeWithObject
            defaultValue={{ value: 'douyin', label: '抖音' }}
            onChange={(value) => console.log('select changed with object', value)}
        />
    );
}
