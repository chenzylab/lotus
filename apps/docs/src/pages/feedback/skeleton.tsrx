import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { BasicSkeletonDemo } from '../../demos/feedback/skeleton/basic.tsrx';
import { CombineImageTitleSkeletonDemo } from '../../demos/feedback/skeleton/combine-image-title.tsrx';
import { CombineDescriptionsSkeletonDemo } from '../../demos/feedback/skeleton/combine-descriptions.tsrx';
import { CombineAvatarTitleSkeletonDemo } from '../../demos/feedback/skeleton/combine-avatar-title.tsrx';
import { CombineCenteredSkeletonDemo } from '../../demos/feedback/skeleton/combine-centered.tsrx';
import { CombineAvatarTitleParagraphSkeletonDemo } from '../../demos/feedback/skeleton/combine-avatar-title-paragraph.tsrx';
import { CombineTableSkeletonDemo } from '../../demos/feedback/skeleton/combine-table.tsrx';
import { ActiveSkeletonDemo } from '../../demos/feedback/skeleton/active.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('feedback/skeleton');
    }
}

import { loadDoc } from server;

/** demo 引用路径（markdown.ts extractDemoRefs 产出的 relativePath）→ 真实 demo 组件的静态映射。 */
const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/feedback/skeleton/basic.tsrx': BasicSkeletonDemo,
    '../../src/demos/feedback/skeleton/combine-image-title.tsrx': CombineImageTitleSkeletonDemo,
    '../../src/demos/feedback/skeleton/combine-descriptions.tsrx': CombineDescriptionsSkeletonDemo,
    '../../src/demos/feedback/skeleton/combine-avatar-title.tsrx': CombineAvatarTitleSkeletonDemo,
    '../../src/demos/feedback/skeleton/combine-centered.tsrx': CombineCenteredSkeletonDemo,
    '../../src/demos/feedback/skeleton/combine-avatar-title-paragraph.tsrx': CombineAvatarTitleParagraphSkeletonDemo,
    '../../src/demos/feedback/skeleton/combine-table.tsrx': CombineTableSkeletonDemo,
    '../../src/demos/feedback/skeleton/active.tsrx': ActiveSkeletonDemo,
};

// module server 生成的客户端桥接函数是异步 RPC 调用，loadDoc() 不能当同步值
// 直接用，必须走 trackAsync + @try/@pending 异步边界；trackAsync 的声明和对
// 其字段的读取必须都在同一个 @try {} 块的直接子级里（不能再包一层普通组件
// 调用），详见 specs/cross-cutting/foundation-adapter-pattern.md 相关记录。
export function SkeletonDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/feedback/skeleton"
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
