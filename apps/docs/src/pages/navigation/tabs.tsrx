import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { TabsBasicDemo } from '../../demos/navigation/tabs/basic.tsrx';
import { TabsIconDemo } from '../../demos/navigation/tabs/icon.tsrx';
import { TabsTypeDemo } from '../../demos/navigation/tabs/type.tsrx';
import { TabsVerticalDemo } from '../../demos/navigation/tabs/vertical.tsrx';
import { TabsDisabledDemo } from '../../demos/navigation/tabs/disabled.tsrx';
import { TabsClosableDemo } from '../../demos/navigation/tabs/closable.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('navigation/tabs');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/navigation/tabs/basic.tsrx': TabsBasicDemo,
    '../../src/demos/navigation/tabs/icon.tsrx': TabsIconDemo,
    '../../src/demos/navigation/tabs/type.tsrx': TabsTypeDemo,
    '../../src/demos/navigation/tabs/vertical.tsrx': TabsVerticalDemo,
    '../../src/demos/navigation/tabs/disabled.tsrx': TabsDisabledDemo,
    '../../src/demos/navigation/tabs/closable.tsrx': TabsClosableDemo,
};

// module server 生成的客户端桥接函数是异步 RPC 调用，loadDoc() 不能当同步值
// 直接用，必须走 trackAsync + @try/@pending 异步边界；trackAsync 的声明和对
// 其字段的读取必须都在同一个 @try {} 块的直接子级里（不能再包一层普通组件
// 调用），详见 specs/cross-cutting/foundation-adapter-pattern.md 相关记录。
export function TabsDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/navigation/tabs"
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
