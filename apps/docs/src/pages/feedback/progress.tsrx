import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { BasicProgressDemo } from '../../demos/feedback/progress/basic.tsrx';
import { CircleProgressDemo } from '../../demos/feedback/progress/circle.tsrx';
import { ControlledProgressDemo } from '../../demos/feedback/progress/controlled.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('feedback/progress');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/feedback/progress/basic.tsrx': BasicProgressDemo,
    '../../src/demos/feedback/progress/circle.tsrx': CircleProgressDemo,
    '../../src/demos/feedback/progress/controlled.tsrx': ControlledProgressDemo,
};

export function ProgressDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/feedback/progress"
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
