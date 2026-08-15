import { Row, Col, Divider } from '@lotus/ripple';

const colContentStyle = {
    background: 'var(--lotus-color-primary-light-default)',
    padding: '8px 0',
    textAlign: 'center',
    borderRadius: 'var(--lotus-border-radius-small)',
};

export function GutterGridDemo() {
    return <div>
        <p>水平间隔</p>
        <Divider />
        <Row gutter={16}>
            <Col span={6}><div style={colContentStyle}>col-6</div></Col>
            <Col span={6}><div style={colContentStyle}>col-6</div></Col>
            <Col span={6}><div style={colContentStyle}>col-6</div></Col>
            <Col span={6}><div style={colContentStyle}>col-6</div></Col>
            <Col span={6}><div style={colContentStyle}>col-6</div></Col>
            <Col span={6}><div style={colContentStyle}>col-6</div></Col>
            <Col span={6}><div style={colContentStyle}>col-6</div></Col>
            <Col span={6}><div style={colContentStyle}>col-6</div></Col>
        </Row>
        <p>垂直间隔</p>
        <Divider />
        <Row gutter={[16, 24]}>
            <Col span={6}><div style={colContentStyle}>col-6</div></Col>
            <Col span={6}><div style={colContentStyle}>col-6</div></Col>
            <Col span={6}><div style={colContentStyle}>col-6</div></Col>
            <Col span={6}><div style={colContentStyle}>col-6</div></Col>
            <Col span={6}><div style={colContentStyle}>col-6</div></Col>
            <Col span={6}><div style={colContentStyle}>col-6</div></Col>
            <Col span={6}><div style={colContentStyle}>col-6</div></Col>
            <Col span={6}><div style={colContentStyle}>col-6</div></Col>
        </Row>
    </div>;
}
