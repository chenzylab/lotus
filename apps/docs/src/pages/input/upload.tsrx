import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { BasicUploadDemo } from '../../demos/input/upload/basic.tsrx';
import { PictureUploadDemo } from '../../demos/input/upload/picture.tsrx';
import { LimitUploadDemo } from '../../demos/input/upload/limit.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('input/upload');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/input/upload/basic.tsrx': BasicUploadDemo,
    '../../src/demos/input/upload/picture.tsrx': PictureUploadDemo,
    '../../src/demos/input/upload/limit.tsrx': LimitUploadDemo,
};

export function UploadDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/input/upload"
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
