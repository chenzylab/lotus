import { track } from 'ripple';
import { SideSheet, Button, TypographyText } from '@lotus/ripple';

export function PlacementLeftSideSheetDemo() @{
    let &[visible] = track<boolean>(false);

    <div>
        <Button onClick={() => { visible = true; }}>打开左侧 SideSheet</Button>
        <SideSheet
            visible={visible}
            placement="left"
            title="左侧 SideSheet"
            onCancel={() => { visible = false; }}
            aria-label="左侧 SideSheet"
        >
            <TypographyText>placement="left" 从左侧滑入。</TypographyText>
        </SideSheet>
    </div>
}
