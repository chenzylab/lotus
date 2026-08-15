import { Tag, Space } from '@lotus/ripple';

export function TagTypeDemo() {
    return <div>
        <div style={{ marginBottom: '8px' }}>
            <Space>
                <Tag color="blue" type="light">light</Tag>
                <Tag color="green" type="light">light</Tag>
                <Tag color="red" type="light">light</Tag>
            </Space>
        </div>
        <div style={{ marginBottom: '8px' }}>
            <Space>
                <Tag color="blue" type="solid">solid</Tag>
                <Tag color="green" type="solid">solid</Tag>
                <Tag color="red" type="solid">solid</Tag>
            </Space>
        </div>
        <div>
            <Space>
                <Tag color="blue" type="ghost">ghost</Tag>
                <Tag color="green" type="ghost">ghost</Tag>
                <Tag color="red" type="ghost">ghost</Tag>
            </Space>
        </div>
    </div>;
}
