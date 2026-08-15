import { Fragment } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { BasicSpaceDemo } from '../../demos/basic/space/basic.tsrx';
import { AlignSpaceDemo } from '../../demos/basic/space/align.tsrx';
import { SpacingSpaceDemo } from '../../demos/basic/space/spacing.tsrx';
import { VerticalSpaceDemo } from '../../demos/basic/space/vertical.tsrx';
import { WrapSpaceDemo } from '../../demos/basic/space/wrap.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export function loadDoc() {
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

export function SpaceDocPage() @{
    const doc = loadDoc();

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
}

function MissingDemo() {
    return <p>Demo 未找到</p>;
}
