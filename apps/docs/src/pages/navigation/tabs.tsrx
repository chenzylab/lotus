import { Fragment } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { TabsBasicDemo } from '../../demos/navigation/tabs/basic.tsrx';
import { TabsIconDemo } from '../../demos/navigation/tabs/icon.tsrx';
import { TabsTypeDemo } from '../../demos/navigation/tabs/type.tsrx';
import { TabsVerticalDemo } from '../../demos/navigation/tabs/vertical.tsrx';
import { TabsDisabledDemo } from '../../demos/navigation/tabs/disabled.tsrx';
import { TabsClosableDemo } from '../../demos/navigation/tabs/closable.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export function loadDoc() {
        return getDoc('navigation/tabs');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/navigation/tabs/basic.tsrx': TabsBasicDemo,
    '../../src/demos/navigation/tabs/icon.tsrx': TabsIconDemo,
    '../../src/demos/navigation/tabs/type.tsrx': TabsTypeDemo,
    '../../src/demos/navigation/tabs/vertical.tsrx': TabsVerticalDemo,
    '../../src/demos/navigation/tabs/disabled.tsrx': TabsDisabledDemo,
    '../../src/demos/navigation/tabs/closable.tsrx': TabsClosableDemo,
};

export function TabsDocPage() @{
    const doc = loadDoc();

    <DocsLayout
        category={doc.frontmatter.category}
        title={doc.title}
        toc={doc.toc}
        currentPath="/navigation/tabs"
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
