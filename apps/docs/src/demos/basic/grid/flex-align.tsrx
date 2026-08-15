import { Row, Col } from '@lotus/ripple';

function colContentStyle(height: number) {
    return {
        background: 'var(--lotus-color-fill-0)',
        height: `${height}px`,
        textAlign: 'center' as const,
        borderRadius: 'var(--lotus-border-radius-small)',
    };
}

export function FlexAlignGridDemo() {
    return <div>
        <p>Align Top</p>
        <Row justify="center" align="top">
            <Col span={4}><div style={colContentStyle(100)}>col-4</div></Col>
            <Col span={4}><div style={colContentStyle(50)}>col-4</div></Col>
            <Col span={4}><div style={colContentStyle(120)}>col-4</div></Col>
            <Col span={4}><div style={colContentStyle(80)}>col-4</div></Col>
        </Row>

        <p>Align Center</p>
        <Row justify="space-around" align="middle">
            <Col span={4}><div style={colContentStyle(100)}>col-4</div></Col>
            <Col span={4}><div style={colContentStyle(50)}>col-4</div></Col>
            <Col span={4}><div style={colContentStyle(120)}>col-4</div></Col>
            <Col span={4}><div style={colContentStyle(80)}>col-4</div></Col>
        </Row>

        <p>Align Bottom</p>
        <Row justify="space-between" align="bottom">
            <Col span={4}><div style={colContentStyle(100)}>col-4</div></Col>
            <Col span={4}><div style={colContentStyle(50)}>col-4</div></Col>
            <Col span={4}><div style={colContentStyle(120)}>col-4</div></Col>
            <Col span={4}><div style={colContentStyle(80)}>col-4</div></Col>
        </Row>
    </div>;
}
