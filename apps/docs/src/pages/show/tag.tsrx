import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { TagBasicDemo } from '../../demos/show/tag/basic.tsrx';
import { TagSizeDemo } from '../../demos/show/tag/size.tsrx';
import { TagIconDemo } from '../../demos/show/tag/icon.tsrx';
import { TagColorDemo } from '../../demos/show/tag/color.tsrx';
import { TagTypeDemo } from '../../demos/show/tag/type.tsrx';
import { TagVisibleDemo } from '../../demos/show/tag/visible.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('show/tag');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/show/tag/basic.tsrx': TagBasicDemo,
    '../../src/demos/show/tag/size.tsrx': TagSizeDemo,
    '../../src/demos/show/tag/icon.tsrx': TagIconDemo,
    '../../src/demos/show/tag/color.tsrx': TagColorDemo,
    '../../src/demos/show/tag/type.tsrx': TagTypeDemo,
    '../../src/demos/show/tag/visible.tsrx': TagVisibleDemo,
};

// module server 生成的客户端桥接函数是异步 RPC 调用，loadDoc() 不能当同步值
// 直接用，必须走 trackAsync + @try/@pending 异步边界；trackAsync 的声明和对
// 其字段的读取必须都在同一个 @try {} 块的直接子级里（不能再包一层普通组件
// 调用），详见 specs/cross-cutting/foundation-adapter-pattern.md 相关记录。
export function TagDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/show/tag"
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
