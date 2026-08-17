import { Select } from '@lotus/ripple';
import type { SelectOption } from '@lotus/ripple';

const options: SelectOption[] = [
    { value: 'douyin', label: '抖音' },
    { value: 'ulikecam', label: '轻颜相机' },
    { value: 'jianying', label: '剪映', disabled: true },
    { value: 'xigua', label: '西瓜视频' },
];

export function SelectMultipleDemo() {
    return (
        <Select
            optionList={options}
            multiple
            defaultValue={['douyin', 'xigua']}
            placeholder="请选择业务线"
            onChange={(value) => console.log('select multiple changed', value)}
            aria-label="多选示例"
        />
    );
}
