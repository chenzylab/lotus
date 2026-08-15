import { Fragment } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { TypographyTitleDemo } from '../../demos/basic/typography/title.tsrx';
import { TypographyTextDemo } from '../../demos/basic/typography/text.tsrx';
import { TypographyParagraphDemo } from '../../demos/basic/typography/paragraph.tsrx';
import { TypographySizeDemo } from '../../demos/basic/typography/size.tsrx';
import { TypographyCopyableDemo } from '../../demos/basic/typography/copyable.tsrx';
import { TypographyEllipsisDemo } from '../../demos/basic/typography/ellipsis.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export function loadDoc() {
        return getDoc('basic/typography');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/basic/typography/title.tsrx': TypographyTitleDemo,
    '../../src/demos/basic/typography/text.tsrx': TypographyTextDemo,
    '../../src/demos/basic/typography/paragraph.tsrx': TypographyParagraphDemo,
    '../../src/demos/basic/typography/size.tsrx': TypographySizeDemo,
    '../../src/demos/basic/typography/copyable.tsrx': TypographyCopyableDemo,
    '../../src/demos/basic/typography/ellipsis.tsrx': TypographyEllipsisDemo,
};

export function TypographyDocPage() @{
    const doc = loadDoc();

    <DocsLayout
        category={doc.frontmatter.category}
        title={doc.title}
        toc={doc.toc}
        currentPath="/basic/typography"
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
