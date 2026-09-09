import { track } from 'ripple';
import { SideSheet, Button, TypographyText } from '@lotus/ripple';

export function PopupContainerSideSheetDemo() @{
    let &[visible] = track<boolean>(false);
    let &[containerNode] = track<HTMLDivElement | null>(null);

    <div
        ref={containerNode}
        style={{ position: 'relative', width: '320px', height: '200px', border: '1px dashed var(--lotus-color-border)', overflow: 'hidden' }}
    >
        <Button onClick={() => { visible = true; }}>打开挂载到虚线容器的 SideSheet</Button>
        <SideSheet
            visible={visible}
            title="挂载到自定义容器"
            getPopupContainer={() => containerNode as HTMLElement}
            onCancel={() => { visible = false; }}
            aria-label="getPopupContainer SideSheet"
        >
            <TypographyText>遮罩与内容都挂载在虚线容器内部。</TypographyText>
        </SideSheet>
    </div>
}
