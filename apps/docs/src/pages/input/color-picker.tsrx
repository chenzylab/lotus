import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { ColorPickerBasicDemo } from '../../demos/input/color-picker/basic.tsrx';
import { ColorPickerPopoverDemo } from '../../demos/input/color-picker/popover.tsrx';
import { ColorPickerNoAlphaDemo } from '../../demos/input/color-picker/no-alpha.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('input/color-picker');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/input/color-picker/basic.tsrx': ColorPickerBasicDemo,
    '../../src/demos/input/color-picker/popover.tsrx': ColorPickerPopoverDemo,
    '../../src/demos/input/color-picker/no-alpha.tsrx': ColorPickerNoAlphaDemo,
};

export function ColorPickerDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/input/color-picker"
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
