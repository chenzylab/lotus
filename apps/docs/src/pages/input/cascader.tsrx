import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { CascaderBasicDemo } from '../../demos/input/cascader/basic.tsrx';
import { CascaderMultipleDemo } from '../../demos/input/cascader/multiple.tsrx';
import { CascaderSearchDemo } from '../../demos/input/cascader/search.tsrx';
import { CascaderClickToSelectDemo } from '../../demos/input/cascader/click-to-select.tsrx';
import { CascaderMaxDemo } from '../../demos/input/cascader/max.tsrx';
import { CascaderMaxTagCountDemo } from '../../demos/input/cascader/max-tag-count.tsrx';
import { CascaderEmptyContentDemo } from '../../demos/input/cascader/empty-content.tsrx';
import { CascaderDisplayRenderDemo } from '../../demos/input/cascader/display-render.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('input/cascader');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/input/cascader/basic.tsrx': CascaderBasicDemo,
    '../../src/demos/input/cascader/multiple.tsrx': CascaderMultipleDemo,
    '../../src/demos/input/cascader/search.tsrx': CascaderSearchDemo,
    '../../src/demos/input/cascader/click-to-select.tsrx': CascaderClickToSelectDemo,
    '../../src/demos/input/cascader/max.tsrx': CascaderMaxDemo,
    '../../src/demos/input/cascader/max-tag-count.tsrx': CascaderMaxTagCountDemo,
    '../../src/demos/input/cascader/empty-content.tsrx': CascaderEmptyContentDemo,
    '../../src/demos/input/cascader/display-render.tsrx': CascaderDisplayRenderDemo,
};

export function CascaderDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/input/cascader"
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
