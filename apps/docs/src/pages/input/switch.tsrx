import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { SwitchBasicDemo } from '../../demos/input/switch/basic.tsrx';
import { SwitchSizeDemo } from '../../demos/input/switch/size.tsrx';
import { SwitchDisabledDemo } from '../../demos/input/switch/disabled.tsrx';
import { SwitchTextDemo } from '../../demos/input/switch/text.tsrx';
import { SwitchControlledDemo } from '../../demos/input/switch/controlled.tsrx';
import { SwitchLoadingDemo } from '../../demos/input/switch/loading.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('input/switch');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/input/switch/basic.tsrx': SwitchBasicDemo,
    '../../src/demos/input/switch/size.tsrx': SwitchSizeDemo,
    '../../src/demos/input/switch/disabled.tsrx': SwitchDisabledDemo,
    '../../src/demos/input/switch/text.tsrx': SwitchTextDemo,
    '../../src/demos/input/switch/controlled.tsrx': SwitchControlledDemo,
    '../../src/demos/input/switch/loading.tsrx': SwitchLoadingDemo,
};

// module server 生成的客户端桥接函数是异步 RPC 调用（见
// packages ripple/src/runtime/internal/client/rpc.js 里的 rpc() 是 async
// 函数），loadDoc() 不能当同步值直接用，必须走 trackAsync + @try/@pending
// 异步边界；服务端 SSR 阶段 render() 原生支持这个边界（流式渲染时以
// pending 内容打底，async 结果就绪后再替换），不会破坏 SSR 输出。
//
// trackAsync 的声明和对其字段的读取必须都在同一个 @try {} 块的直接子级里
// （不能再包一层普通组件调用）——Ripple 运行时对"pending 值读取"的合法
// 位置检测要求 active block 的父级就是 TRY_BLOCK，否则报
// "Reads on pending tracked values ... are prohibited"。
export function SwitchDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/input/switch"
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
