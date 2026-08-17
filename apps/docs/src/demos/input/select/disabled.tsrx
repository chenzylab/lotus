import { Select } from '@lotus/ripple';
import type { SelectOption } from '@lotus/ripple';

const options: SelectOption[] = [
    { value: 'douyin', label: '抖音' },
    { value: 'ulikecam', label: '轻颜相机' },
];

export function SelectDisabledDemo() {
    return <Select optionList={options} disabled defaultValue="douyin" aria-label="禁用示例" />;
}
