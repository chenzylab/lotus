import { track } from 'ripple';
import { Modal, Button, TypographyText } from '@lotus/ripple';

export function MotionKeepDomModalDemo() @{
    let &[noMotionVisible] = track<boolean>(false);
    let &[keepDomVisible] = track<boolean>(false);

    <div style={{ display: 'flex', gap: '12px' }}>
        <div>
            <Button onClick={() => { noMotionVisible = true; }}>打开 motion=false Modal</Button>
            <Modal
                visible={noMotionVisible}
                title="无过渡动画"
                motion={false}
                onOk={() => { noMotionVisible = false; }}
                onCancel={() => { noMotionVisible = false; }}
                aria-label="motion 关闭示例"
            >
                <TypographyText>展开/收起没有 fade+scale 过渡，立即出现/消失。</TypographyText>
            </Modal>
        </div>
        <div>
            <Button onClick={() => { keepDomVisible = true; }}>打开 keepDOM Modal</Button>
            <Modal
                visible={keepDomVisible}
                title="keepDOM 关闭后内容不卸载"
                keepDOM
                onOk={() => { keepDomVisible = false; }}
                onCancel={() => { keepDomVisible = false; }}
                aria-label="keepDOM 示例"
            >
                <div>keepDOM 内容：关闭后这段内容仍在 DOM 中，只是隐藏。</div>
            </Modal>
        </div>
    </div>
}
