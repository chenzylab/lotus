import { Select } from '@lotus/ripple';
import type { SelectOption } from '@lotus/ripple';

const options: SelectOption[] = [
    { value: 'douyin', label: '抖音' },
    { value: 'ulikecam', label: '轻颜相机' },
    { value: 'jianying', label: '剪映', disabled: true },
    { value: 'xigua', label: '西瓜视频' },
];

export function SelectBasicDemo() {
    return <Select optionList={options} defaultValue="douyin" onChange={(value) => console.log('select changed', value)} />;
}
