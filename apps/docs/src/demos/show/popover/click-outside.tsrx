import { Popover, Button, TypographyText } from '@lotus/ripple';
import { track } from 'ripple';

export function ClickOutsidePopoverDemo() @{
    let &[log] = track('等待触发');

    <>
        <Popover
            trigger="click"
            content={<div style={{ padding: '8px 4px' }}>点击外部关闭时会触发回调</div>}
            onClickOutSide={() => { log = '触发了 onClickOutSide'; }}
            onEscKeyDown={() => { log = '触发了 onEscKeyDown'; }}
        >
            <Button theme="outline">点击打开，再点外部或按 Esc</Button>
        </Popover>
        <TypographyText type="secondary" aria-label="回调触发日志" style={{ marginLeft: '12px' }}>{log}</TypographyText>
    </>
}
