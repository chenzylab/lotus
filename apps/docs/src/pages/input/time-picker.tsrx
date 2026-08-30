import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { BasicTimePickerDemo } from '../../demos/input/time-picker/basic.tsrx';
import { RangeTimePickerDemo } from '../../demos/input/time-picker/range.tsrx';
import { DisabledOptionsTimePickerDemo } from '../../demos/input/time-picker/disabled-options.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('input/time-picker');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/input/time-picker/basic.tsrx': BasicTimePickerDemo,
    '../../src/demos/input/time-picker/range.tsrx': RangeTimePickerDemo,
    '../../src/demos/input/time-picker/disabled-options.tsrx': DisabledOptionsTimePickerDemo,
};

export function TimePickerDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/input/time-picker"
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
