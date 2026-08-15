import { Fragment } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { PopoverBasicDemo } from '../../demos/show/popover/basic.tsrx';
import { PopoverPositionDemo } from '../../demos/show/popover/position.tsrx';
import { PopoverControlledDemo } from '../../demos/show/popover/controlled.tsrx';
import { PopoverConditionDemo } from '../../demos/show/popover/condition.tsrx';
import { PopoverArrowDemo } from '../../demos/show/popover/arrow.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export function loadDoc() {
        return getDoc('show/popover');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/show/popover/basic.tsrx': PopoverBasicDemo,
    '../../src/demos/show/popover/position.tsrx': PopoverPositionDemo,
    '../../src/demos/show/popover/controlled.tsrx': PopoverControlledDemo,
    '../../src/demos/show/popover/condition.tsrx': PopoverConditionDemo,
    '../../src/demos/show/popover/arrow.tsrx': PopoverArrowDemo,
};

export function PopoverDocPage() @{
    const doc = loadDoc();

    <DocsLayout
        category={doc.frontmatter.category}
        title={doc.title}
        toc={doc.toc}
        currentPath="/show/popover"
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
