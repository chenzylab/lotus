import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { BasicSpaceDemo } from '../../demos/basic/space/basic.tsrx';
import { AlignSpaceDemo } from '../../demos/basic/space/align.tsrx';
import { SpacingSpaceDemo } from '../../demos/basic/space/spacing.tsrx';
import { VerticalSpaceDemo } from '../../demos/basic/space/vertical.tsrx';
import { WrapSpaceDemo } from '../../demos/basic/space/wrap.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('basic/space');
    }
}

import { loadDoc } from server;

/** demo 引用路径（markdown.ts extractDemoRefs 产出的 relativePath）→ 真实 demo 组件的静态映射。 */
const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/basic/space/basic.tsrx': BasicSpaceDemo,
    '../../src/demos/basic/space/align.tsrx': AlignSpaceDemo,
    '../../src/demos/basic/space/spacing.tsrx': SpacingSpaceDemo,
    '../../src/demos/basic/space/vertical.tsrx': VerticalSpaceDemo,
    '../../src/demos/basic/space/wrap.tsrx': WrapSpaceDemo,
};

// module server 生成的客户端桥接函数是异步 RPC 调用，loadDoc() 不能当同步值
// 直接用，必须走 trackAsync + @try/@pending 异步边界；trackAsync 的声明和对
// 其字段的读取必须都在同一个 @try {} 块的直接子级里（不能再包一层普通组件
// 调用），详见 specs/cross-cutting/foundation-adapter-pattern.md 相关记录。
export function SpaceDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/basic/space"
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
