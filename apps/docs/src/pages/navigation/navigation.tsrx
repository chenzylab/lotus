import { Fragment, trackAsync } from 'ripple';
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
    export async function loadDoc() {
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

// module server 生成的客户端桥接函数是异步 RPC 调用，loadDoc() 不能当同步值
// 直接用，必须走 trackAsync + @try/@pending 异步边界；trackAsync 的声明和对
// 其字段的读取必须都在同一个 @try {} 块的直接子级里（不能再包一层普通组件
// 调用），详见 specs/cross-cutting/foundation-adapter-pattern.md 相关记录。
export function NavigationDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
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
    } @pending {
        <p>Loading...</p>
    }
}

function MissingDemo() {
    return <p>Demo 未找到</p>;
}
