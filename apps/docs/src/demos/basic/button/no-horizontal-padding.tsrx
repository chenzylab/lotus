import { Button, Space } from '@lotus/ripple';
import { IconTickCircle } from '@lotus/icons';

export function NoHorizontalPaddingButtonDemo() @{
    <Space>
        <Button icon={<IconTickCircle />} aria-label="默认水平内边距" />
        <Button icon={<IconTickCircle />} aria-label="去除两侧内边距" noHorizontalPadding />
        <Button icon={<IconTickCircle />} aria-label="仅去除左侧内边距" noHorizontalPadding="left" />
        <Button icon={<IconTickCircle />} aria-label="仅去除右侧内边距" noHorizontalPadding="right" />
    </Space>
}
