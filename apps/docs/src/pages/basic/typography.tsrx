import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { TypographyTitleDemo } from '../../demos/basic/typography/title.tsrx';
import { TypographyTextDemo } from '../../demos/basic/typography/text.tsrx';
import { TypographyParagraphDemo } from '../../demos/basic/typography/paragraph.tsrx';
import { TypographySizeDemo } from '../../demos/basic/typography/size.tsrx';
import { TypographyCopyableDemo } from '../../demos/basic/typography/copyable.tsrx';
import { TypographyEllipsisDemo } from '../../demos/basic/typography/ellipsis.tsrx';
import { ComponentTypographyDemo } from '../../demos/basic/typography/component.tsrx';
import { NumeralTypographyDemo } from '../../demos/basic/typography/numeral.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('basic/typography');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/basic/typography/title.tsrx': TypographyTitleDemo,
    '../../src/demos/basic/typography/text.tsrx': TypographyTextDemo,
    '../../src/demos/basic/typography/paragraph.tsrx': TypographyParagraphDemo,
    '../../src/demos/basic/typography/size.tsrx': TypographySizeDemo,
    '../../src/demos/basic/typography/copyable.tsrx': TypographyCopyableDemo,
    '../../src/demos/basic/typography/ellipsis.tsrx': TypographyEllipsisDemo,
    '../../src/demos/basic/typography/component.tsrx': ComponentTypographyDemo,
    '../../src/demos/basic/typography/numeral.tsrx': NumeralTypographyDemo,
};

// module server 生成的客户端桥接函数是异步 RPC 调用，loadDoc() 不能当同步值
// 直接用，必须走 trackAsync + @try/@pending 异步边界；trackAsync 的声明和对
// 其字段的读取必须都在同一个 @try {} 块的直接子级里（不能再包一层普通组件
// 调用），详见 specs/cross-cutting/foundation-adapter-pattern.md 相关记录。
export function TypographyDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/basic/typography"
        >
            @for (const fragment of doc.fragments; index i) {
                @if (fragment.type === 'html') {
                    <Fragment innerHTML={fragment.html} />
                } @else {
                    <DocDemoCard highlightedSource={fragment.highlightedSource}>
                        <{DEMO_COMPONENTS[fragment.demo.relativePath] ?? MissingDemo} />
                    </DocDemoCard>
                }
            }
        </DocsLayout>
    } @pending {
        <p>Loading...</p>
    }
}

function MissingDemo() {
    return <p>Demo 未找到</p>;
}
