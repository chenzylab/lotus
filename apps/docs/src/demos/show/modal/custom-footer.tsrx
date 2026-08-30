import { track } from 'ripple';
import { Modal, Button, TypographyText } from '@lotus/ripple';

export function CustomFooterModalDemo() @{
    let &[visible] = track<boolean>(false);

    <div>
        <Button onClick={() => { visible = true; }}>打开自定义 footer Modal</Button>
        <Modal
            visible={visible}
            title="自定义 footer"
            footer={
                <Button theme="solid" type="danger" onClick={() => { visible = false; }}>
                    我知道了
                </Button>
            }
            onCancel={() => { visible = false; }}
            aria-label="自定义 footer Modal"
        >
            <TypographyText>只有一个自定义按钮的 footer。</TypographyText>
        </Modal>
    </div>
}
