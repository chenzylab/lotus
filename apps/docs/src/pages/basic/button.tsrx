import { Fragment } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { ButtonTypeDemo } from '../../demos/basic/button/type.tsrx';
import { ButtonThemeDemo } from '../../demos/basic/button/theme.tsrx';
import { ButtonSizeDemo } from '../../demos/basic/button/size.tsrx';
import { ButtonBlockDemo } from '../../demos/basic/button/block.tsrx';
import { ButtonIconDemo } from '../../demos/basic/button/icon.tsrx';
import { ButtonDisabledDemo } from '../../demos/basic/button/disabled.tsrx';
import { ButtonLoadingDemo } from '../../demos/basic/button/loading.tsrx';
import { ButtonGroupDemo } from '../../demos/basic/button/group.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export function loadDoc() {
        return getDoc('basic/button');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/basic/button/type.tsrx': ButtonTypeDemo,
    '../../src/demos/basic/button/theme.tsrx': ButtonThemeDemo,
    '../../src/demos/basic/button/size.tsrx': ButtonSizeDemo,
    '../../src/demos/basic/button/block.tsrx': ButtonBlockDemo,
    '../../src/demos/basic/button/icon.tsrx': ButtonIconDemo,
    '../../src/demos/basic/button/disabled.tsrx': ButtonDisabledDemo,
    '../../src/demos/basic/button/loading.tsrx': ButtonLoadingDemo,
    '../../src/demos/basic/button/group.tsrx': ButtonGroupDemo,
};

export function ButtonDocPage() @{
    const doc = loadDoc();

    <DocsLayout
        category={doc.frontmatter.category}
        title={doc.title}
        toc={doc.toc}
        currentPath="/basic/button"
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
