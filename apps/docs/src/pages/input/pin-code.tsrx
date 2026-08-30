import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { PinCodeBasicDemo } from '../../demos/input/pin-code/basic.tsrx';
import { PinCodeMixedDemo } from '../../demos/input/pin-code/mixed.tsrx';
import { PinCodeValidateStatusDemo } from '../../demos/input/pin-code/validate-status.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('input/pin-code');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/input/pin-code/basic.tsrx': PinCodeBasicDemo,
    '../../src/demos/input/pin-code/mixed.tsrx': PinCodeMixedDemo,
    '../../src/demos/input/pin-code/validate-status.tsrx': PinCodeValidateStatusDemo,
};

export function PinCodeDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/input/pin-code"
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
