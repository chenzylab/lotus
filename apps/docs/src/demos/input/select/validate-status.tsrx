import { Select } from '@lotus/ripple';
import type { SelectOptionData } from '@lotus/ripple';

const options: SelectOptionData[] = [
    { value: 'douyin', label: '抖音' },
    { value: 'ulikecam', label: '轻颜相机' },
];

export function SelectValidateStatusDemo() {
    return <Select optionList={options} validateStatus="error" placeholder="请选择" aria-label="错误状态示例" />;
}
