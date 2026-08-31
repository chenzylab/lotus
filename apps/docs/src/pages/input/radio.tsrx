import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { RadioBasicDemo } from '../../demos/input/radio/basic.tsrx';
import { RadioDisabledDemo } from '../../demos/input/radio/disabled.tsrx';
import { RadioControlledDemo } from '../../demos/input/radio/controlled.tsrx';
import { RadioAdvancedModeDemo } from '../../demos/input/radio/advanced-mode.tsrx';
import { RadioGroupOptionsDemo } from '../../demos/input/radio/group-options.tsrx';
import { RadioGroupJsxDemo } from '../../demos/input/radio/group-jsx.tsrx';
import { RadioGroupButtonDemo } from '../../demos/input/radio/group-button.tsrx';
import { RadioGroupCardDemo } from '../../demos/input/radio/group-card.tsrx';
import { RadioGroupPureCardDemo } from '../../demos/input/radio/group-pure-card.tsrx';
import { ImperativeRadioDemo } from '../../demos/input/radio/imperative.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('input/radio');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/input/radio/basic.tsrx': RadioBasicDemo,
    '../../src/demos/input/radio/disabled.tsrx': RadioDisabledDemo,
    '../../src/demos/input/radio/controlled.tsrx': RadioControlledDemo,
    '../../src/demos/input/radio/advanced-mode.tsrx': RadioAdvancedModeDemo,
    '../../src/demos/input/radio/group-options.tsrx': RadioGroupOptionsDemo,
    '../../src/demos/input/radio/group-jsx.tsrx': RadioGroupJsxDemo,
    '../../src/demos/input/radio/group-button.tsrx': RadioGroupButtonDemo,
    '../../src/demos/input/radio/group-card.tsrx': RadioGroupCardDemo,
    '../../src/demos/input/radio/group-pure-card.tsrx': RadioGroupPureCardDemo,
    '../../src/demos/input/radio/imperative.tsrx': ImperativeRadioDemo,
};

// module server 生成的客户端桥接函数是异步 RPC 调用，loadDoc() 不能当同步值
// 直接用，必须走 trackAsync + @try/@pending 异步边界；trackAsync 的声明和对
// 其字段的读取必须都在同一个 @try {} 块的直接子级里（不能再包一层普通组件
// 调用），详见 specs/cross-cutting/foundation-adapter-pattern.md 相关记录。
export function RadioDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/input/radio"
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
