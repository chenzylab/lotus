import { Space, Button, Tag } from '@lotus/ripple';

const boxStyle = {
    width: '80px',
    height: '100px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    border: '1px solid var(--lotus-color-border)',
    borderRadius: '3px',
};

export function AlignSpaceDemo() {
    return <Space vertical>
        <Space align="start">
            <div style={boxStyle}>文本</div>
            <Button theme="solid" type="primary">按钮</Button>
            <Tag color="green" size="large">标签</Tag>
        </Space>
        <Space align="center">
            <div style={boxStyle}>文本</div>
            <Button theme="solid" type="primary">按钮</Button>
            <Tag color="green" size="large">标签</Tag>
        </Space>
        <Space align="end">
            <div style={boxStyle}>文本</div>
            <Button theme="solid" type="primary">按钮</Button>
            <Tag color="green" size="large">标签</Tag>
        </Space>
        <Space align="baseline">
            <div style={boxStyle}>文本</div>
            <Button theme="solid" type="primary">按钮</Button>
            <Tag color="green" size="large">标签</Tag>
        </Space>
    </Space>;
}
