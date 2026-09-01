import { Select } from '@lotus/ripple';
import type { SelectOptionListEntry } from '@lotus/ripple';

const groupedOptions: SelectOptionListEntry[] = [
    { label: '短视频', options: [{ value: 'douyin', label: '抖音' }, { value: 'xigua', label: '西瓜视频' }] },
    { label: '影像工具', options: [{ value: 'ulikecam', label: '轻颜相机' }, { value: 'jianying', label: '剪映', disabled: true }] },
];

export function SelectGroupDemo() {
    return <Select optionList={groupedOptions} placeholder="请选择" />;
}
