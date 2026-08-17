import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { BasicGridDemo } from '../../demos/basic/grid/basic.tsrx';
import { GutterGridDemo } from '../../demos/basic/grid/gutter.tsrx';
import { OffsetGridDemo } from '../../demos/basic/grid/offset.tsrx';
import { FlexLayoutGridDemo } from '../../demos/basic/grid/flex-layout.tsrx';
import { FlexAlignGridDemo } from '../../demos/basic/grid/flex-align.tsrx';
import { OrderGridDemo } from '../../demos/basic/grid/order.tsrx';
import { ResponsiveGridDemo } from '../../demos/basic/grid/responsive.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('basic/grid');
    }
}

import { loadDoc } from server;

/** demo 引用路径（markdown.ts extractDemoRefs 产出的 relativePath）→ 真实 demo 组件的静态映射。 */
const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/basic/grid/basic.tsrx': BasicGridDemo,
    '../../src/demos/basic/grid/gutter.tsrx': GutterGridDemo,
    '../../src/demos/basic/grid/offset.tsrx': OffsetGridDemo,
    '../../src/demos/basic/grid/flex-layout.tsrx': FlexLayoutGridDemo,
    '../../src/demos/basic/grid/flex-align.tsrx': FlexAlignGridDemo,
    '../../src/demos/basic/grid/order.tsrx': OrderGridDemo,
    '../../src/demos/basic/grid/responsive.tsrx': ResponsiveGridDemo,
};

// module server 生成的客户端桥接函数是异步 RPC 调用，loadDoc() 不能当同步值
// 直接用，必须走 trackAsync + @try/@pending 异步边界；trackAsync 的声明和对
// 其字段的读取必须都在同一个 @try {} 块的直接子级里（不能再包一层普通组件
// 调用），详见 specs/cross-cutting/foundation-adapter-pattern.md 相关记录。
export function GridDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/basic/grid"
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
