import { Select } from '@lotus/ripple';
import type { SelectOptionData } from '@lotus/ripple';

const options: SelectOptionData[] = [
    { value: 'douyin', label: '抖音' },
    { value: 'ulikecam', label: '轻颜相机' },
    { value: 'jianying', label: '剪映', disabled: true },
    { value: 'xigua', label: '西瓜视频' },
];

export function SelectFilterDemo() {
    return (
        <Select
            optionList={options}
            filter
            placeholder="请选择业务线（可搜索）"
            aria-label="filter 示例"
        />
    );
}
