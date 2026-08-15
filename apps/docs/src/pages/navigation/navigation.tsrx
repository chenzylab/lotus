import { Fragment } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { BasicNavDemo } from '../../demos/navigation/navigation/basic.tsrx';
import { StyleNavDemo } from '../../demos/navigation/navigation/style.tsrx';
import { JsxNavDemo } from '../../demos/navigation/navigation/jsx.tsrx';
import { RouterNavDemo } from '../../demos/navigation/navigation/router.tsrx';
import { VerticalNavDemo } from '../../demos/navigation/navigation/vertical.tsrx';
import { HorizontalNavDemo } from '../../demos/navigation/navigation/horizontal.tsrx';
import { HorizontalVerticalNavDemo } from '../../demos/navigation/navigation/horizontal-vertical.tsrx';
import { ToggleIconPositionNavDemo } from '../../demos/navigation/navigation/toggle-icon-position.tsrx';
import { IndentNavDemo } from '../../demos/navigation/navigation/indent.tsrx';
import { UncontrolledNavDemo } from '../../demos/navigation/navigation/uncontrolled.tsrx';
import { ControlledNavDemo } from '../../demos/navigation/navigation/controlled.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export function loadDoc() {
        return getDoc('navigation/navigation');
    }
}

import { loadDoc } from server;

/** demo 引用路径（markdown.ts extractDemoRefs 产出的 relativePath）→ 真实 demo 组件的静态映射。 */
const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/navigation/navigation/basic.tsrx': BasicNavDemo,
    '../../src/demos/navigation/navigation/style.tsrx': StyleNavDemo,
    '../../src/demos/navigation/navigation/jsx.tsrx': JsxNavDemo,
    '../../src/demos/navigation/navigation/router.tsrx': RouterNavDemo,
    '../../src/demos/navigation/navigation/vertical.tsrx': VerticalNavDemo,
    '../../src/demos/navigation/navigation/horizontal.tsrx': HorizontalNavDemo,
    '../../src/demos/navigation/navigation/horizontal-vertical.tsrx': HorizontalVerticalNavDemo,
    '../../src/demos/navigation/navigation/toggle-icon-position.tsrx': ToggleIconPositionNavDemo,
    '../../src/demos/navigation/navigation/indent.tsrx': IndentNavDemo,
    '../../src/demos/navigation/navigation/uncontrolled.tsrx': UncontrolledNavDemo,
    '../../src/demos/navigation/navigation/controlled.tsrx': ControlledNavDemo,
};

export function NavigationDocPage() @{
    const doc = loadDoc();

    <DocsLayout
        category={doc.frontmatter.category}
        title={doc.title}
        toc={doc.toc}
        currentPath="/navigation/navigation"
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
