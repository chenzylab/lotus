import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { BasicPaginationDemo } from '../../demos/navigation/pagination/basic.tsrx';
import { FullPaginationDemo } from '../../demos/navigation/pagination/full.tsrx';
import { SmallPaginationDemo } from '../../demos/navigation/pagination/small.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('navigation/pagination');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/navigation/pagination/basic.tsrx': BasicPaginationDemo,
    '../../src/demos/navigation/pagination/full.tsrx': FullPaginationDemo,
    '../../src/demos/navigation/pagination/small.tsrx': SmallPaginationDemo,
};

export function PaginationDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/navigation/pagination"
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
