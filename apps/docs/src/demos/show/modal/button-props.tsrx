import { track } from 'ripple';
import { Modal, Button, TypographyText } from '@lotus/ripple';

export function ButtonPropsModalDemo() @{
    let &[visible] = track<boolean>(false);

    <div>
        <Button onClick={() => { visible = true; }}>打开自定义按钮 props 的 Modal</Button>
        <Modal
            visible={visible}
            title="自定义按钮 props"
            cancelButtonProps={{ type: 'warning' }}
            okButtonProps={{ type: 'danger' }}
            onOk={() => { visible = false; }}
            onCancel={() => { visible = false; }}
            aria-label="cancelButtonProps okButtonProps 示例"
        >
            <TypographyText>取消按钮为 warning 类型，确认按钮为 danger 类型。</TypographyText>
        </Modal>
    </div>
}
