import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { BasicTransferDemo } from '../../demos/input/transfer/basic.tsrx';
import { GroupTransferDemo } from '../../demos/input/transfer/group.tsrx';
import { DraggableTransferDemo } from '../../demos/input/transfer/draggable.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('input/transfer');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/input/transfer/basic.tsrx': BasicTransferDemo,
    '../../src/demos/input/transfer/group.tsrx': GroupTransferDemo,
    '../../src/demos/input/transfer/draggable.tsrx': DraggableTransferDemo,
};

export function TransferDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/input/transfer"
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
