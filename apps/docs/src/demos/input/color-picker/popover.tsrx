import { ColorPicker, Button } from '@lotus/ripple';

export function ColorPickerPopoverDemo() @{
    <ColorPicker usePopover aria-label="弹层拾色器">
        <Button>点击选择颜色</Button>
    </ColorPicker>
}
