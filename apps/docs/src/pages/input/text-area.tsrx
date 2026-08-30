import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { BasicTextAreaDemo } from '../../demos/input/text-area/basic.tsrx';
import { AutosizeTextAreaDemo } from '../../demos/input/text-area/autosize.tsrx';
import { CountClearTextAreaDemo } from '../../demos/input/text-area/count-clear.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('input/text-area');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/input/text-area/basic.tsrx': BasicTextAreaDemo,
    '../../src/demos/input/text-area/autosize.tsrx': AutosizeTextAreaDemo,
    '../../src/demos/input/text-area/count-clear.tsrx': CountClearTextAreaDemo,
};

export function TextAreaDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/input/text-area"
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
