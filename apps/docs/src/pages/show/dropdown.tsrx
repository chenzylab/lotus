import { Fragment } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { DropdownBasicDemo } from '../../demos/show/dropdown/basic.tsrx';
import { DropdownNestedDemo } from '../../demos/show/dropdown/nested.tsrx';
import { DropdownPositionDemo } from '../../demos/show/dropdown/position.tsrx';
import { DropdownTriggerDemo } from '../../demos/show/dropdown/trigger.tsrx';
import { DropdownEventDemo } from '../../demos/show/dropdown/event.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export function loadDoc() {
        return getDoc('show/dropdown');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/show/dropdown/basic.tsrx': DropdownBasicDemo,
    '../../src/demos/show/dropdown/nested.tsrx': DropdownNestedDemo,
    '../../src/demos/show/dropdown/position.tsrx': DropdownPositionDemo,
    '../../src/demos/show/dropdown/trigger.tsrx': DropdownTriggerDemo,
    '../../src/demos/show/dropdown/event.tsrx': DropdownEventDemo,
};

export function DropdownDocPage() @{
    const doc = loadDoc();

    <DocsLayout
        category={doc.frontmatter.category}
        title={doc.title}
        toc={doc.toc}
        currentPath="/show/dropdown"
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
}

function MissingDemo() {
    return <p>Demo 未找到</p>;
}
