import { Fragment } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { TooltipBasicDemo } from '../../demos/show/tooltip/basic.tsrx';
import { TooltipPositionDemo } from '../../demos/show/tooltip/position.tsrx';
import { TooltipTriggerDemo } from '../../demos/show/tooltip/trigger.tsrx';
import { TooltipConditionDemo } from '../../demos/show/tooltip/condition.tsrx';
import { TooltipCustomDemo } from '../../demos/show/tooltip/custom.tsrx';
import { TooltipNoArrowDemo } from '../../demos/show/tooltip/no-arrow.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export function loadDoc() {
        return getDoc('show/tooltip');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/show/tooltip/basic.tsrx': TooltipBasicDemo,
    '../../src/demos/show/tooltip/position.tsrx': TooltipPositionDemo,
    '../../src/demos/show/tooltip/trigger.tsrx': TooltipTriggerDemo,
    '../../src/demos/show/tooltip/condition.tsrx': TooltipConditionDemo,
    '../../src/demos/show/tooltip/custom.tsrx': TooltipCustomDemo,
    '../../src/demos/show/tooltip/no-arrow.tsrx': TooltipNoArrowDemo,
};

export function TooltipDocPage() @{
    const doc = loadDoc();

    <DocsLayout
        category={doc.frontmatter.category}
        title={doc.title}
        toc={doc.toc}
        currentPath="/show/tooltip"
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
