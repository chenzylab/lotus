import { Fragment } from 'ripple';
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
    export function loadDoc() {
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

export function TagDocPage() @{
    const doc = loadDoc();

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
}

function MissingDemo() {
    return <p>Demo 未找到</p>;
}
