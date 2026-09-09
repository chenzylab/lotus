import { track } from 'ripple';
import { SideSheet, Button, TypographyText } from '@lotus/ripple';

export function CloseIconMotionSideSheetDemo() @{
    let &[visible] = track<boolean>(false);

    <div>
        <Button onClick={() => { visible = true; }}>打开 closeIcon/motion=false SideSheet</Button>
        <SideSheet
            visible={visible}
            title="自定义关闭图标 + 无过渡动画"
            closeIcon={<span>✕</span>}
            motion={false}
            onCancel={() => { visible = false; }}
            aria-label="closeIcon motion SideSheet"
        >
            <TypographyText>右上角关闭按钮用自定义 closeIcon，展开/收起没有过渡动画。</TypographyText>
        </SideSheet>
    </div>
}
