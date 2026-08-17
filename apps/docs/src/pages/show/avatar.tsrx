import { Fragment, trackAsync } from 'ripple';
import { DocsLayout } from '../../components/docs-layout.tsrx';
import { DocDemoCard } from '../../components/doc-demo-card.tsrx';
import { AvatarSizeDemo } from '../../demos/show/avatar/size.tsrx';
import { AvatarColorDemo } from '../../demos/show/avatar/color.tsrx';
import { AvatarGapDemo } from '../../demos/show/avatar/gap.tsrx';
import { AvatarImageDemo } from '../../demos/show/avatar/image.tsrx';
import { AvatarShapeDemo } from '../../demos/show/avatar/shape.tsrx';
import { AvatarEventDemo } from '../../demos/show/avatar/event.tsrx';
import { AvatarSlotDemo } from '../../demos/show/avatar/slot.tsrx';
import { AvatarBorderDemo } from '../../demos/show/avatar/border.tsrx';
import { AvatarMotionDemo } from '../../demos/show/avatar/motion.tsrx';
import { AvatarGroupDemo } from '../../demos/show/avatar/group.tsrx';

module server {
    import { getDoc } from '../../lib/markdown';
    export async function loadDoc() {
        return getDoc('show/avatar');
    }
}

import { loadDoc } from server;

const DEMO_COMPONENTS: Record<string, any> = {
    '../../src/demos/show/avatar/size.tsrx': AvatarSizeDemo,
    '../../src/demos/show/avatar/color.tsrx': AvatarColorDemo,
    '../../src/demos/show/avatar/gap.tsrx': AvatarGapDemo,
    '../../src/demos/show/avatar/image.tsrx': AvatarImageDemo,
    '../../src/demos/show/avatar/shape.tsrx': AvatarShapeDemo,
    '../../src/demos/show/avatar/event.tsrx': AvatarEventDemo,
    '../../src/demos/show/avatar/slot.tsrx': AvatarSlotDemo,
    '../../src/demos/show/avatar/border.tsrx': AvatarBorderDemo,
    '../../src/demos/show/avatar/motion.tsrx': AvatarMotionDemo,
    '../../src/demos/show/avatar/group.tsrx': AvatarGroupDemo,
};

// module server 生成的客户端桥接函数是异步 RPC 调用，loadDoc() 不能当同步值
// 直接用，必须走 trackAsync + @try/@pending 异步边界；trackAsync 的声明和对
// 其字段的读取必须都在同一个 @try {} 块的直接子级里（不能再包一层普通组件
// 调用），详见 specs/cross-cutting/foundation-adapter-pattern.md 相关记录。
export function AvatarDocPage() @{
    let &[doc] = trackAsync(() => loadDoc());

    @try {
        <DocsLayout
            category={doc.frontmatter.category}
            title={doc.title}
            toc={doc.toc}
            currentPath="/show/avatar"
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
