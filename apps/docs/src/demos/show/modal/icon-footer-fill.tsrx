import { track } from 'ripple';
import { Modal, Button, TypographyText } from '@lotus/ripple';

export function IconFooterFillModalDemo() @{
    let &[visible] = track<boolean>(false);

    <div>
        <Button onClick={() => { visible = true; }}>打开 icon/closeIcon/footerFill Modal</Button>
        <Modal
            visible={visible}
            title="带图标 + 自定义关闭图标 + 底部按钮撑满"
            icon={<span style={{ fontSize: '18px' }}>⚠️</span>}
            closeIcon={<span>✕</span>}
            footerFill
            onOk={() => { visible = false; }}
            onCancel={() => { visible = false; }}
            aria-label="icon closeIcon footerFill 示例"
        >
            <TypographyText>标题左侧有自定义 icon，右上角关闭按钮用自定义 closeIcon，底部两个按钮撑满宽度。</TypographyText>
        </Modal>
    </div>
}
