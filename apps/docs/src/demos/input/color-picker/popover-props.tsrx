import { ColorPicker, Button } from '@lotus/ripple';

export function ColorPickerPopoverPropsDemo() @{
    <ColorPicker usePopover popoverProps={{ position: 'right' }} aria-label="自定义弹层位置的拾色器">
        <Button>右侧弹出</Button>
    </ColorPicker>
}
