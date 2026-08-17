import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { InputBasicDemo } from '../../demos/input/input/basic.tsrx';
import { InputSizeDemo } from '../../demos/input/input/size.tsrx';
import { InputDisabledDemo } from '../../demos/input/input/disabled.tsrx';
import { InputAffixDemo } from '../../demos/input/input/affix.tsrx';
import { InputAddonDemo } from '../../demos/input/input/addon.tsrx';
import { InputPasswordDemo } from '../../demos/input/input/password.tsrx';
import { InputValidateStatusDemo } from '../../demos/input/input/validate-status.tsrx';
import { InputControlledDemo } from '../../demos/input/input/controlled.tsrx';
import { TextAreaBasicDemo } from '../../demos/input/input/textarea-basic.tsrx';
import { TextAreaAutosizeDemo } from '../../demos/input/input/textarea-autosize.tsrx';
import { TextAreaCountDemo } from '../../demos/input/input/textarea-count.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('input/input');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/input/input/basic.tsrx': InputBasicDemo,
    '../../src/demos/input/input/size.tsrx': InputSizeDemo,
    '../../src/demos/input/input/disabled.tsrx': InputDisabledDemo,
    '../../src/demos/input/input/affix.tsrx': InputAffixDemo,
    '../../src/demos/input/input/addon.tsrx': InputAddonDemo,
    '../../src/demos/input/input/password.tsrx': InputPasswordDemo,
    '../../src/demos/input/input/validate-status.tsrx': InputValidateStatusDemo,
    '../../src/demos/input/input/controlled.tsrx': InputControlledDemo,
    '../../src/demos/input/input/textarea-basic.tsrx': TextAreaBasicDemo,
    '../../src/demos/input/input/textarea-autosize.tsrx': TextAreaAutosizeDemo,
    '../../src/demos/input/input/textarea-count.tsrx': TextAreaCountDemo,
};

// module server 生成的客户端桥接函数是异步 RPC 调用，loadDoc() 不能当同步值
// 直接用，必须走 trackAsync + @try/@pending 异步边界；trackAsync 的声明和对
// 其字段的读取必须都在同一个 @try {} 块的直接子级里（不能再包一层普通组件
// 调用），详见 specs/cross-cutting/foundation-adapter-pattern.md 相关记录。
export function InputDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/input/input"
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
