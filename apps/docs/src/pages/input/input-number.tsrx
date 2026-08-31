import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { InputNumberBasicDemo } from '../../demos/input/input-number/basic.tsrx';
import { InputNumberSizeDemo } from '../../demos/input/input-number/size.tsrx';
import { InputNumberBoundaryDemo } from '../../demos/input/input-number/boundary.tsrx';
import { InputNumberDisabledDemo } from '../../demos/input/input-number/disabled.tsrx';
import { InputNumberClearDemo } from '../../demos/input/input-number/clear.tsrx';
import { InputNumberControlledDemo } from '../../demos/input/input-number/controlled.tsrx';
import { FormatInputNumberDemo } from '../../demos/input/input-number/format.tsrx';
import { InnerButtonsInputNumberDemo } from '../../demos/input/input-number/inner-buttons.tsrx';
import { ScientificNotationInputNumberDemo } from '../../demos/input/input-number/scientific-notation.tsrx';
import { CurrencyInputNumberDemo } from '../../demos/input/input-number/currency.tsrx';
import { ImperativeInputNumberDemo } from '../../demos/input/input-number/imperative.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('input/input-number');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/input/input-number/basic.tsrx': InputNumberBasicDemo,
    '../../src/demos/input/input-number/size.tsrx': InputNumberSizeDemo,
    '../../src/demos/input/input-number/boundary.tsrx': InputNumberBoundaryDemo,
    '../../src/demos/input/input-number/disabled.tsrx': InputNumberDisabledDemo,
    '../../src/demos/input/input-number/clear.tsrx': InputNumberClearDemo,
    '../../src/demos/input/input-number/controlled.tsrx': InputNumberControlledDemo,
    '../../src/demos/input/input-number/format.tsrx': FormatInputNumberDemo,
    '../../src/demos/input/input-number/inner-buttons.tsrx': InnerButtonsInputNumberDemo,
    '../../src/demos/input/input-number/scientific-notation.tsrx': ScientificNotationInputNumberDemo,
    '../../src/demos/input/input-number/currency.tsrx': CurrencyInputNumberDemo,
    '../../src/demos/input/input-number/imperative.tsrx': ImperativeInputNumberDemo,
};

// module server 生成的客户端桥接函数是异步 RPC 调用，loadDoc() 不能当同步值
// 直接用，必须走 trackAsync + @try/@pending 异步边界；trackAsync 的声明和对
// 其字段的读取必须都在同一个 @try {} 块的直接子级里（不能再包一层普通组件
// 调用），详见 specs/cross-cutting/foundation-adapter-pattern.md 相关记录。
export function InputNumberDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/input/input-number"
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
