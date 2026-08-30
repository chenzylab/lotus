import { IconButton, Space } from '@lotus/ripple';
import { IconSetting } from '@lotus/icons';

export function StateIconButtonDemo() {
    return <Space>
        <IconButton icon={<IconSetting />} size="small" aria-label="设置" />
        <IconButton icon={<IconSetting />} size="default" aria-label="设置" />
        <IconButton icon={<IconSetting />} size="large" aria-label="设置" />
        <IconButton icon={<IconSetting />} loading aria-label="设置" />
        <IconButton icon={<IconSetting />} disabled aria-label="设置" />
    </Space>;
}
