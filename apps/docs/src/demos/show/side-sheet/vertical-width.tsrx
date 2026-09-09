import { track } from 'ripple';
import { SideSheet, Button, TypographyText } from '@lotus/ripple';

export function VerticalWidthSideSheetDemo() @{
    let &[visible] = track<boolean>(false);

    <div>
        <Button onClick={() => { visible = true; }}>打开固定宽度的顶部 SideSheet</Button>
        <SideSheet
            visible={visible}
            title="top 放置 + canVerticalSetWidth + width"
            placement="top"
            canVerticalSetWidth
            width={400}
            onCancel={() => { visible = false; }}
            aria-label="canVerticalSetWidth SideSheet"
        >
            <TypographyText>默认 top/bottom 放置宽度铺满 100%，canVerticalSetWidth 开启后可用 width 指定固定宽度（居左，不会自动居中）。</TypographyText>
        </SideSheet>
    </div>
}
