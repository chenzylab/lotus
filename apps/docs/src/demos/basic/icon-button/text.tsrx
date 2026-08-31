import { IconButton, Space } from '@lotus/ripple';
import { IconSetting } from '@lotus/icons';

export function TextIconButtonDemo() {
    return <Space>
        <IconButton icon={<IconSetting />}>图标在左</IconButton>
        <IconButton icon={<IconSetting />} iconPosition="right">图标在右</IconButton>
        <IconButton icon={<IconSetting />} noHorizontalPadding="left">无左侧内边距</IconButton>
    </Space>;
}
