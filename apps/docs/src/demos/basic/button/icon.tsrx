import { Button, Space } from '@lotus/ripple';
import { IconCamera, IconSidebar, IconChevronDown } from '@lotus/icons';

export function ButtonIconDemo() {
    return <Space vertical align="start">
        <div>
            <strong>默认状态：</strong>
            <Button icon={<IconCamera />} aria-label="截屏" />
        </div>
        <div>
            <strong>禁用状态：</strong>
            <Button disabled icon={<IconCamera />} aria-label="截屏" />
        </div>
        <div>
            <strong>复合类型：</strong>
            <Space>
                <Button type="primary" icon={<IconCamera />} aria-label="截屏" />
                <Button type="secondary" icon={<IconCamera />} aria-label="截屏" />
                <Button type="warning" icon={<IconCamera />} aria-label="截屏" />
                <Button type="danger" icon={<IconCamera />} aria-label="截屏" />
            </Space>
        </div>
        <div>
            <strong>更改主题：</strong>
            <Space>
                <Button icon={<IconCamera />} theme="solid" aria-label="截屏" />
                <Button icon={<IconCamera />} theme="light" aria-label="截屏" />
            </Space>
        </div>
        <div>
            <strong>更改图标位置：</strong>
            <Space>
                <Button icon={<IconSidebar />} theme="solid">收起</Button>
                <Button icon={<IconChevronDown />} theme="solid" iconPosition="right">展开选项</Button>
            </Space>
        </div>
    </Space>;
}
