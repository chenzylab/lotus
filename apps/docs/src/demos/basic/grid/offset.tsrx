import { Row, Col } from '@lotus/ripple';

const colContentStyle = {
    background: 'var(--lotus-color-fill-0)',
    padding: '8px 0',
    textAlign: 'center',
    borderRadius: 'var(--lotus-border-radius-small)',
};

export function OffsetGridDemo() {
    return <div>
        <Row>
            <Col span={8}><div style={colContentStyle}>col-8</div></Col>
            <Col span={8} offset={8}><div style={colContentStyle}>col-8</div></Col>
        </Row>
        <br />
        <Row>
            <Col span={6} offset={6}><div style={colContentStyle}>col-6</div></Col>
            <Col span={6} offset={6}><div style={colContentStyle}>col-6</div></Col>
        </Row>
        <br />
        <Row>
            <Col span={12} offset={6}><div style={colContentStyle}>col-12</div></Col>
        </Row>
    </div>;
}
