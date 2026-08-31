import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { PopoverBasicDemo } from '../../demos/show/popover/basic.tsrx';
import { PopoverPositionDemo } from '../../demos/show/popover/position.tsrx';
import { PopoverControlledDemo } from '../../demos/show/popover/controlled.tsrx';
import { PopoverConditionDemo } from '../../demos/show/popover/condition.tsrx';
import { PopoverArrowDemo } from '../../demos/show/popover/arrow.tsrx';
import { ArrowPointAtCenterPopoverDemo } from '../../demos/show/popover/arrow-point-at-center.tsrx';
import { ClickOutsidePopoverDemo } from '../../demos/show/popover/click-outside.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('show/popover');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/show/popover/basic.tsrx': PopoverBasicDemo,
    '../../src/demos/show/popover/position.tsrx': PopoverPositionDemo,
    '../../src/demos/show/popover/controlled.tsrx': PopoverControlledDemo,
    '../../src/demos/show/popover/condition.tsrx': PopoverConditionDemo,
    '../../src/demos/show/popover/arrow.tsrx': PopoverArrowDemo,
    '../../src/demos/show/popover/arrow-point-at-center.tsrx': ArrowPointAtCenterPopoverDemo,
    '../../src/demos/show/popover/click-outside.tsrx': ClickOutsidePopoverDemo,
};

// module server 生成的客户端桥接函数是异步 RPC 调用，loadDoc() 不能当同步值
// 直接用，必须走 trackAsync + @try/@pending 异步边界；trackAsync 的声明和对
// 其字段的读取必须都在同一个 @try {} 块的直接子级里（不能再包一层普通组件
// 调用），详见 specs/cross-cutting/foundation-adapter-pattern.md 相关记录。
export function PopoverDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/show/popover"
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
