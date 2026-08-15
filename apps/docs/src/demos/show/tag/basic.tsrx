import { Tag, Space } from '@lotus/ripple';

export function TagBasicDemo() {
    return <Space>
        <Tag>标签一</Tag>
        <Tag closable onClose={() => console.log('tag closed')}>可关闭标签</Tag>
    </Space>;
}
