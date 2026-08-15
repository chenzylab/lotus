import { Row, Col } from '@lotus/ripple';

const colContentStyle = {
    background: 'var(--lotus-color-fill-0)',
    padding: '8px 0',
    textAlign: 'center',
    borderRadius: 'var(--lotus-border-radius-small)',
};

export function FlexLayoutGridDemo() {
    return <div>
        <p>子元素居左</p>
        <Row justify="start">
            <Col span={4}><div style={colContentStyle}>col-4</div></Col>
            <Col span={4}><div style={colContentStyle}>col-4</div></Col>
            <Col span={4}><div style={colContentStyle}>col-4</div></Col>
            <Col span={4}><div style={colContentStyle}>col-4</div></Col>
        </Row>

        <p>子元素居中</p>
        <Row justify="center">
            <Col span={4}><div style={colContentStyle}>col-4</div></Col>
            <Col span={4}><div style={colContentStyle}>col-4</div></Col>
            <Col span={4}><div style={colContentStyle}>col-4</div></Col>
            <Col span={4}><div style={colContentStyle}>col-4</div></Col>
        </Row>

        <p>子元素居右</p>
        <Row justify="end">
            <Col span={4}><div style={colContentStyle}>col-4</div></Col>
            <Col span={4}><div style={colContentStyle}>col-4</div></Col>
            <Col span={4}><div style={colContentStyle}>col-4</div></Col>
            <Col span={4}><div style={colContentStyle}>col-4</div></Col>
        </Row>

        <p>等间距排列</p>
        <Row justify="space-between">
            <Col span={4}><div style={colContentStyle}>col-4</div></Col>
            <Col span={4}><div style={colContentStyle}>col-4</div></Col>
            <Col span={4}><div style={colContentStyle}>col-4</div></Col>
            <Col span={4}><div style={colContentStyle}>col-4</div></Col>
        </Row>

        <p>分散排列</p>
        <Row justify="space-around">
            <Col span={4}><div style={colContentStyle}>col-4</div></Col>
            <Col span={4}><div style={colContentStyle}>col-4</div></Col>
            <Col span={4}><div style={colContentStyle}>col-4</div></Col>
            <Col span={4}><div style={colContentStyle}>col-4</div></Col>
        </Row>
    </div>;
}
