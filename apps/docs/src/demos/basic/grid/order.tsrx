import { Row, Col } from '@lotus/ripple';

const colContentStyle = {
    background: 'var(--lotus-color-fill-0)',
    padding: '8px 0',
    textAlign: 'center',
    borderRadius: 'var(--lotus-border-radius-small)',
};

export function OrderGridDemo() {
    return <Row>
        <Col span={6} order={4}><div style={colContentStyle}>col-4</div></Col>
        <Col span={6} order={3}><div style={colContentStyle}>col-3</div></Col>
        <Col span={6} order={2}><div style={colContentStyle}>col-2</div></Col>
        <Col span={6} order={1}><div style={colContentStyle}>col-1</div></Col>
    </Row>;
}
