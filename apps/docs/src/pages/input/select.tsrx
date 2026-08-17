import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { SelectBasicDemo } from '../../demos/input/select/basic.tsrx';
import { SelectSizeDemo } from '../../demos/input/select/size.tsrx';
import { SelectDisabledDemo } from '../../demos/input/select/disabled.tsrx';
import { SelectValidateStatusDemo } from '../../demos/input/select/validate-status.tsrx';
import { SelectClearDemo } from '../../demos/input/select/clear.tsrx';
import { SelectMultipleDemo } from '../../demos/input/select/multiple.tsrx';
import { SelectControlledDemo } from '../../demos/input/select/controlled.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('input/select');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/input/select/basic.tsrx': SelectBasicDemo,
    '../../src/demos/input/select/size.tsrx': SelectSizeDemo,
    '../../src/demos/input/select/disabled.tsrx': SelectDisabledDemo,
    '../../src/demos/input/select/validate-status.tsrx': SelectValidateStatusDemo,
    '../../src/demos/input/select/clear.tsrx': SelectClearDemo,
    '../../src/demos/input/select/multiple.tsrx': SelectMultipleDemo,
    '../../src/demos/input/select/controlled.tsrx': SelectControlledDemo,
};

// module server 生成的客户端桥接函数是异步 RPC 调用，loadDoc() 不能当同步值
// 直接用，必须走 trackAsync + @try/@pending 异步边界；trackAsync 的声明和对
// 其字段的读取必须都在同一个 @try {} 块的直接子级里（不能再包一层普通组件
// 调用），详见 specs/cross-cutting/foundation-adapter-pattern.md 相关记录。
export function SelectDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/input/select"
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
