import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { BasicStepsDemo } from '../../demos/navigation/steps/basic.tsrx';
import { FillStepsDemo } from '../../demos/navigation/steps/fill.tsrx';
import { VerticalErrorStepsDemo } from '../../demos/navigation/steps/vertical-error.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('navigation/steps');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/navigation/steps/basic.tsrx': BasicStepsDemo,
    '../../src/demos/navigation/steps/fill.tsrx': FillStepsDemo,
    '../../src/demos/navigation/steps/vertical-error.tsrx': VerticalErrorStepsDemo,
};

export function StepsDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/navigation/steps"
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
