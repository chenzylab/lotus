import { DatePicker, TypographyText } from '@lotus/ripple';

export function DatePickerSlotsDemo() @{
    <div style={{ width: '260px' }}>
        <DatePicker
            topSlot={<TypographyText type="secondary">常用日期</TypographyText>}
            bottomSlot={<TypographyText type="tertiary">提示：点击日期选中</TypographyText>}
            aria-label="带插槽的日期选择器"
        />
    </div>
}
