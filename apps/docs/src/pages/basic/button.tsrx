import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { ButtonTypeDemo } from '../../demos/basic/button/type.tsrx';
import { ButtonThemeDemo } from '../../demos/basic/button/theme.tsrx';
import { ButtonSizeDemo } from '../../demos/basic/button/size.tsrx';
import { ButtonBlockDemo } from '../../demos/basic/button/block.tsrx';
import { ButtonIconDemo } from '../../demos/basic/button/icon.tsrx';
import { ButtonDisabledDemo } from '../../demos/basic/button/disabled.tsrx';
import { ButtonLoadingDemo } from '../../demos/basic/button/loading.tsrx';
import { ButtonGroupDemo } from '../../demos/basic/button/group.tsrx';
import { ColorfulButtonDemo } from '../../demos/basic/button/colorful.tsrx';
import { NoHorizontalPaddingButtonDemo } from '../../demos/basic/button/no-horizontal-padding.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('basic/button');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/basic/button/type.tsrx': ButtonTypeDemo,
    '../../src/demos/basic/button/theme.tsrx': ButtonThemeDemo,
    '../../src/demos/basic/button/size.tsrx': ButtonSizeDemo,
    '../../src/demos/basic/button/block.tsrx': ButtonBlockDemo,
    '../../src/demos/basic/button/icon.tsrx': ButtonIconDemo,
    '../../src/demos/basic/button/disabled.tsrx': ButtonDisabledDemo,
    '../../src/demos/basic/button/loading.tsrx': ButtonLoadingDemo,
    '../../src/demos/basic/button/group.tsrx': ButtonGroupDemo,
    '../../src/demos/basic/button/colorful.tsrx': ColorfulButtonDemo,
    '../../src/demos/basic/button/no-horizontal-padding.tsrx': NoHorizontalPaddingButtonDemo,
};

// module server 生成的客户端桥接函数是异步 RPC 调用，loadDoc() 不能当同步值
// 直接用，必须走 trackAsync + @try/@pending 异步边界；trackAsync 的声明和对
// 其字段的读取必须都在同一个 @try {} 块的直接子级里（不能再包一层普通组件
// 调用），详见 specs/cross-cutting/foundation-adapter-pattern.md 相关记录。
export function ButtonDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/basic/button"
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
