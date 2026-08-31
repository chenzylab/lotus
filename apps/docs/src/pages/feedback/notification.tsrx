import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { BasicNotificationDemo } from '../../demos/feedback/notification/basic.tsrx';
import { ThemeNotificationDemo } from '../../demos/feedback/notification/theme.tsrx';
import { CallbackNotificationDemo } from '../../demos/feedback/notification/callback.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('feedback/notification');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/feedback/notification/basic.tsrx': BasicNotificationDemo,
    '../../src/demos/feedback/notification/theme.tsrx': ThemeNotificationDemo,
    '../../src/demos/feedback/notification/callback.tsrx': CallbackNotificationDemo,
};

export function NotificationDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/feedback/notification"
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
