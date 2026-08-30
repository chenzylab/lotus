import { track } from 'ripple';
import { Modal, Button, TypographyText } from '@lotus/ripple';

export function BasicModalDemo() @{
    let &[visible] = track<boolean>(false);

    <div>
        <Button onClick={() => { visible = true; }}>打开基础 Modal</Button>
        <Modal
            visible={visible}
            title="基础 Modal"
            onOk={() => { visible = false; }}
            onCancel={() => { visible = false; }}
            aria-label="基础 Modal"
        >
            <TypographyText>这是 Modal 的内容区域。</TypographyText>
        </Modal>
    </div>
}
