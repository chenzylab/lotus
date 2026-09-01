import { Select } from '@lotus/ripple';
import type { SelectOptionData } from '@lotus/ripple';

const options: SelectOptionData[] = [
    { value: 'douyin', label: '抖音' },
    { value: 'xigua', label: '西瓜视频' },
];

export function SelectLoadingDemo() {
    return <Select optionList={options} loading placeholder="加载中" />;
}
