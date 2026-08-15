import { Fragment } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { ThreeRowLayoutDemo } from '../../demos/basic/layout/three-row.tsrx';
import { LeftSiderLayoutDemo } from '../../demos/basic/layout/left-sider.tsrx';
import { RightSiderLayoutDemo } from '../../demos/basic/layout/right-sider.tsrx';
import { FullSiderLayoutDemo } from '../../demos/basic/layout/full-sider.tsrx';
import { ResponsiveLayoutDemo } from '../../demos/basic/layout/responsive.tsrx';
import { TopNavLayoutDemo } from '../../demos/basic/layout/top-nav.tsrx';
import { TopSideNavLayoutDemo } from '../../demos/basic/layout/top-side-nav.tsrx';
import { SideNavLayoutDemo } from '../../demos/basic/layout/side-nav.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export function loadDoc() {
        return getDoc('basic/layout');
    }
}

import { loadDoc } from server;

/** demo 引用路径（markdown.ts extractDemoRefs 产出的 relativePath）→ 真实 demo 组件的静态映射。 */
const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/basic/layout/three-row.tsrx': ThreeRowLayoutDemo,
    '../../src/demos/basic/layout/left-sider.tsrx': LeftSiderLayoutDemo,
    '../../src/demos/basic/layout/right-sider.tsrx': RightSiderLayoutDemo,
    '../../src/demos/basic/layout/full-sider.tsrx': FullSiderLayoutDemo,
    '../../src/demos/basic/layout/responsive.tsrx': ResponsiveLayoutDemo,
    '../../src/demos/basic/layout/top-nav.tsrx': TopNavLayoutDemo,
    '../../src/demos/basic/layout/top-side-nav.tsrx': TopSideNavLayoutDemo,
    '../../src/demos/basic/layout/side-nav.tsrx': SideNavLayoutDemo,
};

export function LayoutDocPage() @{
    const doc = loadDoc();

    <DocsLayout
        category={doc.frontmatter.category}
        title={doc.title}
        toc={doc.toc}
        currentPath="/basic/layout"
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
