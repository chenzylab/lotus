import { TypographyNumeral, Space } from '@lotus/ripple';

export function NumeralTypographyDemo() @{
    <Space vertical align="start">
        <TypographyNumeral rule="percentages" precision={2} aria-label="百分比格式化" children="0.4567" />
        <TypographyNumeral rule="bytes-decimal" precision={2} aria-label="字节格式化（十进制）" children="1500000" />
        <TypographyNumeral rule="exponential" truncate="floor" precision={2} aria-label="科学计数法格式化" children="Total revenue: $ 1992.15" />
    </Space>
}
