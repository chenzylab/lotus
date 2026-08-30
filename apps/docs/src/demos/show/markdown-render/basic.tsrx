import { MarkdownRender } from '@lotus/ripple';

const RAW = `# 标题

支持 **加粗**、*斜体*、\`行内代码\`。

- 列表项一
- 列表项二

\`\`\`js
console.log('hello');
\`\`\`
`;

export function BasicMarkdownRenderDemo() @{
    <MarkdownRender raw={RAW} />
}
