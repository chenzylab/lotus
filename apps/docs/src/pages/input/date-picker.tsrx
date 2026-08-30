import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { DatePickerBasicDemo } from '../../demos/input/date-picker/basic.tsrx';
import { DatePickerRangeDemo } from '../../demos/input/date-picker/range.tsrx';
import { DatePickerTypeVariantsDemo } from '../../demos/input/date-picker/type-variants.tsrx';
import { DatePickerDisabledDatePresetsDemo } from '../../demos/input/date-picker/disabled-date-presets.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('input/date-picker');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/input/date-picker/basic.tsrx': DatePickerBasicDemo,
    '../../src/demos/input/date-picker/range.tsrx': DatePickerRangeDemo,
    '../../src/demos/input/date-picker/type-variants.tsrx': DatePickerTypeVariantsDemo,
    '../../src/demos/input/date-picker/disabled-date-presets.tsrx': DatePickerDisabledDatePresetsDemo,
};

export function DatePickerDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/input/date-picker"
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
