import { Select } from '@lotus/ripple';
import type { SelectOption } from '@lotus/ripple';

const options: SelectOption[] = [
    { value: 'douyin', label: '抖音' },
    { value: 'ulikecam', label: '轻颜相机' },
];

export function SelectValidateStatusDemo() {
    return <Select optionList={options} validateStatus="error" placeholder="请选择" aria-label="错误状态示例" />;
}
