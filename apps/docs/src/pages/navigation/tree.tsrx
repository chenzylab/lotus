import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { BasicTreeDemo } from '../../demos/navigation/tree/basic.tsrx';
import { MultipleTreeDemo } from '../../demos/navigation/tree/multiple.tsrx';
import { SearchTreeDemo } from '../../demos/navigation/tree/search.tsrx';
import { LazyTreeDemo } from '../../demos/navigation/tree/lazy.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('navigation/tree');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/navigation/tree/basic.tsrx': BasicTreeDemo,
    '../../src/demos/navigation/tree/multiple.tsrx': MultipleTreeDemo,
    '../../src/demos/navigation/tree/search.tsrx': SearchTreeDemo,
    '../../src/demos/navigation/tree/lazy.tsrx': LazyTreeDemo,
};

export function TreeDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/navigation/tree"
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
