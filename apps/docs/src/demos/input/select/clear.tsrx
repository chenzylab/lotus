import { Select } from '@lotus/ripple';
import type { SelectOption } from '@lotus/ripple';

const options: SelectOption[] = [
    { value: 'douyin', label: '抖音' },
    { value: 'ulikecam', label: '轻颜相机' },
];

export function SelectClearDemo() {
    return <Select optionList={options} showClear defaultValue="douyin" aria-label="可清除示例" />;
}
