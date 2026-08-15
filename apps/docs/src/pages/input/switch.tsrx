import { Fragment } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { SwitchBasicDemo } from '../../demos/input/switch/basic.tsrx';
import { SwitchSizeDemo } from '../../demos/input/switch/size.tsrx';
import { SwitchDisabledDemo } from '../../demos/input/switch/disabled.tsrx';
import { SwitchTextDemo } from '../../demos/input/switch/text.tsrx';
import { SwitchControlledDemo } from '../../demos/input/switch/controlled.tsrx';
import { SwitchLoadingDemo } from '../../demos/input/switch/loading.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export function loadDoc() {
        return getDoc('input/switch');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/input/switch/basic.tsrx': SwitchBasicDemo,
    '../../src/demos/input/switch/size.tsrx': SwitchSizeDemo,
    '../../src/demos/input/switch/disabled.tsrx': SwitchDisabledDemo,
    '../../src/demos/input/switch/text.tsrx': SwitchTextDemo,
    '../../src/demos/input/switch/controlled.tsrx': SwitchControlledDemo,
    '../../src/demos/input/switch/loading.tsrx': SwitchLoadingDemo,
};

export function SwitchDocPage() @{
    const doc = loadDoc();

    <DocsLayout
        category={doc.frontmatter.category}
        title={doc.title}
        toc={doc.toc}
        currentPath="/input/switch"
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
