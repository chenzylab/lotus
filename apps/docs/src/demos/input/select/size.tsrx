import { Select, Space } from '@lotus/ripple';
import type { SelectOption } from '@lotus/ripple';

const options: SelectOption[] = [
    { value: 'douyin', label: '抖音' },
    { value: 'ulikecam', label: '轻颜相机' },
];

export function SelectSizeDemo() {
    return (
        <Space>
            <Select optionList={options} size="large" defaultValue="douyin" aria-label="large" />
            <Select optionList={options} size="default" defaultValue="douyin" aria-label="default" />
            <Select optionList={options} size="small" defaultValue="douyin" aria-label="small" />
        </Space>
    );
}
