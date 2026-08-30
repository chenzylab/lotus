import { IconButton, Space } from '@lotus/ripple';
import { IconSetting } from '@lotus/icons';

export function BasicIconButtonDemo() {
    return <Space>
        <IconButton icon={<IconSetting />} aria-label="设置" />
        <IconButton icon={<IconSetting />} theme="light" aria-label="设置" />
        <IconButton icon={<IconSetting />} theme="solid" aria-label="设置" />
        <IconButton icon={<IconSetting />} theme="outline" aria-label="设置" />
    </Space>;
}
