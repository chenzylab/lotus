import { Anchor } from '@lotus/ripple';

export function NestedAnchorDemo() @{
    <div style={{ display: 'flex', gap: '24px' }}>
        <Anchor
            links={[
                {
                    href: '#anchor-nested-1',
                    title: '第一章',
                    children: [
                        { href: '#anchor-nested-1-1', title: '1.1 节' },
                        { href: '#anchor-nested-1-2', title: '1.2 节' },
                    ],
                },
                { href: '#anchor-nested-2', title: '第二章' },
            ]}
            getContainer={() => document.getElementById('anchor-nested-scroll-container')!}
            aria-label="嵌套锚点导航"
        />
        <div id="anchor-nested-scroll-container" style={{ width: '320px', height: '200px', overflowY: 'auto', border: '1px solid var(--lotus-color-border)', padding: '12px' }}>
            <div id="anchor-nested-1" style={{ height: '80px' }}>第一章</div>
            <div id="anchor-nested-1-1" style={{ height: '140px' }}>1.1 节内容</div>
            <div id="anchor-nested-1-2" style={{ height: '140px' }}>1.2 节内容</div>
            <div id="anchor-nested-2" style={{ height: '200px' }}>第二章内容</div>
        </div>
    </div>
}
