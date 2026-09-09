import { track } from 'ripple';
import { Modal, Button, TypographyText } from '@lotus/ripple';

export function PopupContainerModalDemo() @{
    let &[visible] = track<boolean>(false);
    let &[containerNode] = track<HTMLDivElement | null>(null);

    <div
        ref={containerNode}
        style={{ position: 'relative', width: '320px', height: '160px', border: '1px dashed var(--lotus-color-border)', overflow: 'hidden' }}
    >
        <Button onClick={() => { visible = true; }}>打开挂载到虚线容器的 Modal</Button>
        <Modal
            visible={visible}
            title="挂载到自定义容器"
            getPopupContainer={() => containerNode as HTMLElement}
            onOk={() => { visible = false; }}
            onCancel={() => { visible = false; }}
            aria-label="getPopupContainer 示例"
        >
            <TypographyText>遮罩与内容都挂载在虚线容器内部（position: absolute 相对定位）。</TypographyText>
        </Modal>
    </div>
}
