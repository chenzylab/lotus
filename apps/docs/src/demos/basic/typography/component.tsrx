import { TypographyText, TypographyTitle, TypographyParagraph, Space } from '@lotus/ripple';

export function ComponentTypographyDemo() @{
    <Space vertical align="start">
        <TypographyText component="div" aria-label="Text 渲染为 div">Text 渲染为 div（默认应为 span）</TypographyText>
        <TypographyTitle heading={3} component="div" aria-label="Title 渲染为 div">Title heading=3 但渲染为 div（默认应为 h3）</TypographyTitle>
        <TypographyParagraph component="span" aria-label="Paragraph 渲染为 span">Paragraph 渲染为 span（默认应为 p）</TypographyParagraph>
    </Space>
}
