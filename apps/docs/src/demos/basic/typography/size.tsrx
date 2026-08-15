import { TypographyText, TypographyParagraph, Space } from '@lotus/ripple';

export function TypographySizeDemo() {
    return <Space vertical align="start">
        <TypographyText size="normal">normal 尺寸文本</TypographyText>
        <TypographyText size="small">small 尺寸文本</TypographyText>
        <TypographyParagraph size="normal">normal 尺寸段落文本</TypographyParagraph>
        <TypographyParagraph size="small">small 尺寸段落文本</TypographyParagraph>
    </Space>;
}
