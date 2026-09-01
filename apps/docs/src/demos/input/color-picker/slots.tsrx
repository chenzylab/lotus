import { ColorPicker, TypographyText } from '@lotus/ripple';

export function ColorPickerSlotsDemo() @{
    <ColorPicker
        topSlot={<TypographyText type="secondary">常用色</TypographyText>}
        bottomSlot={<TypographyText type="tertiary">提示：拖拽或输入数值调整颜色</TypographyText>}
        aria-label="带插槽的拾色器"
    />
}
