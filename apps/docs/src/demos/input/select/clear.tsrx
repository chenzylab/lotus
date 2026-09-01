import { Select } from '@lotus/ripple';
import type { SelectOptionData } from '@lotus/ripple';

const options: SelectOptionData[] = [
    { value: 'douyin', label: '抖音' },
    { value: 'ulikecam', label: '轻颜相机' },
];

export function SelectClearDemo() {
    return <Select optionList={options} showClear defaultValue="douyin" aria-label="可清除示例" />;
}
