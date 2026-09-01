import { Select, SelectOption, SelectOptGroup } from '@lotus/ripple';

export function SelectGroupJsxDemo() {
    return (
        <Select placeholder="请选择">
            <SelectOptGroup label="短视频">
                <SelectOption value="douyin" label="抖音" />
                <SelectOption value="xigua" label="西瓜视频" />
            </SelectOptGroup>
            <SelectOptGroup label="影像工具">
                <SelectOption value="ulikecam" label="轻颜相机" />
                <SelectOption value="jianying" label="剪映" disabled />
            </SelectOptGroup>
        </Select>
    );
}
