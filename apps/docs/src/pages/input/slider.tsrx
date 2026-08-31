import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { SliderBasicDemo } from '../../demos/input/slider/basic.tsrx';
import { SliderRangeDemo } from '../../demos/input/slider/range.tsrx';
import { SliderMarksDemo } from '../../demos/input/slider/marks.tsrx';
import { CustomizationSliderDemo } from '../../demos/input/slider/customization.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('input/slider');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/input/slider/basic.tsrx': SliderBasicDemo,
    '../../src/demos/input/slider/range.tsrx': SliderRangeDemo,
    '../../src/demos/input/slider/marks.tsrx': SliderMarksDemo,
    '../../src/demos/input/slider/customization.tsrx': CustomizationSliderDemo,
};

export function SliderDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/input/slider"
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
