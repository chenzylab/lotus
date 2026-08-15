import { Fragment } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { BasicBreadcrumbDemo } from '../../demos/navigation/breadcrumb/basic.tsrx';
import { WithIconBreadcrumbDemo } from '../../demos/navigation/breadcrumb/with-icon.tsrx';
import { SizeBreadcrumbDemo } from '../../demos/navigation/breadcrumb/size.tsrx';
import { SeparatorBreadcrumbDemo } from '../../demos/navigation/breadcrumb/separator.tsrx';
import { TruncateBreadcrumbDemo } from '../../demos/navigation/breadcrumb/truncate.tsrx';
import { CollapseBreadcrumbDemo } from '../../demos/navigation/breadcrumb/collapse.tsrx';
import { MoreTypeBreadcrumbDemo } from '../../demos/navigation/breadcrumb/more-type.tsrx';
import { RenderMoreBreadcrumbDemo } from '../../demos/navigation/breadcrumb/render-more.tsrx';
import { RouteObjectBreadcrumbDemo } from '../../demos/navigation/breadcrumb/route-object.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export function loadDoc() {
        return getDoc('navigation/breadcrumb');
    }
}

import { loadDoc } from server;

/** demo 引用路径（markdown.ts extractDemoRefs 产出的 relativePath）→ 真实 demo 组件的静态映射。 */
const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/navigation/breadcrumb/basic.tsrx': BasicBreadcrumbDemo,
    '../../src/demos/navigation/breadcrumb/with-icon.tsrx': WithIconBreadcrumbDemo,
    '../../src/demos/navigation/breadcrumb/size.tsrx': SizeBreadcrumbDemo,
    '../../src/demos/navigation/breadcrumb/separator.tsrx': SeparatorBreadcrumbDemo,
    '../../src/demos/navigation/breadcrumb/truncate.tsrx': TruncateBreadcrumbDemo,
    '../../src/demos/navigation/breadcrumb/collapse.tsrx': CollapseBreadcrumbDemo,
    '../../src/demos/navigation/breadcrumb/more-type.tsrx': MoreTypeBreadcrumbDemo,
    '../../src/demos/navigation/breadcrumb/render-more.tsrx': RenderMoreBreadcrumbDemo,
    '../../src/demos/navigation/breadcrumb/route-object.tsrx': RouteObjectBreadcrumbDemo,
};

export function BreadcrumbDocPage() @{
    const doc = loadDoc();

    <DocsLayout
        category={doc.frontmatter.category}
        title={doc.title}
        toc={doc.toc}
        currentPath="/navigation/breadcrumb"
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
