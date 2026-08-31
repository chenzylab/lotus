import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { CheckboxBasicDemo } from '../../demos/input/checkbox/basic.tsrx';
import { CheckboxDisabledDemo } from '../../demos/input/checkbox/disabled.tsrx';
import { CheckboxIndeterminateDemo } from '../../demos/input/checkbox/indeterminate.tsrx';
import { CheckboxControlledDemo } from '../../demos/input/checkbox/controlled.tsrx';
import { CheckboxGroupOptionsDemo } from '../../demos/input/checkbox/group-options.tsrx';
import { CheckboxGroupJsxDemo } from '../../demos/input/checkbox/group-jsx.tsrx';
import { CheckboxGroupCardDemo } from '../../demos/input/checkbox/group-card.tsrx';
import { CheckboxGroupPureCardDemo } from '../../demos/input/checkbox/group-pure-card.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('input/checkbox');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/input/checkbox/basic.tsrx': CheckboxBasicDemo,
    '../../src/demos/input/checkbox/disabled.tsrx': CheckboxDisabledDemo,
    '../../src/demos/input/checkbox/indeterminate.tsrx': CheckboxIndeterminateDemo,
    '../../src/demos/input/checkbox/controlled.tsrx': CheckboxControlledDemo,
    '../../src/demos/input/checkbox/group-options.tsrx': CheckboxGroupOptionsDemo,
    '../../src/demos/input/checkbox/group-jsx.tsrx': CheckboxGroupJsxDemo,
    '../../src/demos/input/checkbox/group-card.tsrx': CheckboxGroupCardDemo,
    '../../src/demos/input/checkbox/group-pure-card.tsrx': CheckboxGroupPureCardDemo,
};

// module server 生成的客户端桥接函数是异步 RPC 调用，loadDoc() 不能当同步值
// 直接用，必须走 trackAsync + @try/@pending 异步边界；trackAsync 的声明和对
// 其字段的读取必须都在同一个 @try {} 块的直接子级里（不能再包一层普通组件
// 调用），详见 specs/cross-cutting/foundation-adapter-pattern.md 相关记录。
export function CheckboxDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/input/checkbox"
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
