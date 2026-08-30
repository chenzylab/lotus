import { MarkdownRender } from '@lotus/ripple';

const RAW = `| 姓名 | 年龄 |
| --- | --- |
| 张三 | 28 |
| 李四 | 32 |

- [x] GFM 任务列表已完成项
- [ ] 未完成项
`;

export function GfmTableMarkdownRenderDemo() @{
    <MarkdownRender raw={RAW} remarkGfm />
}
