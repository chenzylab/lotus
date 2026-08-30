import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { BasicAiChatDialogueDemo } from '../../demos/show/ai-chat-dialogue/basic.tsrx';
import { StreamingAiChatDialogueDemo } from '../../demos/show/ai-chat-dialogue/streaming.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('show/ai-chat-dialogue');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/show/ai-chat-dialogue/basic.tsrx': BasicAiChatDialogueDemo,
    '../../src/demos/show/ai-chat-dialogue/streaming.tsrx': StreamingAiChatDialogueDemo,
};

export function AiChatDialogueDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/show/ai-chat-dialogue"
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
