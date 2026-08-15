import { TypographyText, Space } from '@lotus/ripple';

export function TypographyTextDemo() {
    return <Space wrap>
        <TypographyText>默认文本</TypographyText>
        <TypographyText type="secondary">次要文本</TypographyText>
        <TypographyText type="tertiary">三级文本</TypographyText>
        <TypographyText type="warning">警示文本</TypographyText>
        <TypographyText type="danger">危险文本</TypographyText>
        <TypographyText type="success">成功文本</TypographyText>
        <TypographyText disabled>禁用文本</TypographyText>
        <TypographyText mark>标记文本</TypographyText>
        <TypographyText code>code 文本</TypographyText>
        <TypographyText delete>删除线文本</TypographyText>
        <TypographyText underline>下划线文本</TypographyText>
        <TypographyText strong>加粗文本</TypographyText>
        <TypographyText link={{ href: 'https://example.com', target: '_blank' }}>链接文本</TypographyText>
    </Space>;
}
