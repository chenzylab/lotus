import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { BasicTreeSelectDemo } from '../../demos/input/tree-select/basic.tsrx';
import { MultipleTreeSelectDemo } from '../../demos/input/tree-select/multiple.tsrx';
import { SearchTreeSelectDemo } from '../../demos/input/tree-select/search.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('input/tree-select');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/input/tree-select/basic.tsrx': BasicTreeSelectDemo,
    '../../src/demos/input/tree-select/multiple.tsrx': MultipleTreeSelectDemo,
    '../../src/demos/input/tree-select/search.tsrx': SearchTreeSelectDemo,
};

export function TreeSelectDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/input/tree-select"
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
