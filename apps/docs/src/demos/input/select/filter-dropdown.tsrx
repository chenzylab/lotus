import { Select } from '@lotus/ripple';
import type { SelectOptionData } from '@lotus/ripple';

const options: SelectOptionData[] = [
    { value: 'douyin', label: '抖音' },
    { value: 'ulikecam', label: '轻颜相机' },
    { value: 'jianying', label: '剪映', disabled: true },
    { value: 'xigua', label: '西瓜视频' },
];

export function SelectFilterDropdownDemo() {
    return (
        <Select
            optionList={options}
            filter
            searchPosition="dropdown"
            searchPlaceholder="搜索业务线"
            placeholder="请选择业务线"
            aria-label="filter dropdown 示例"
        />
    );
}
