import { Anchor } from '@lotus/ripple';

export function BasicAnchorDemo() @{
    <div style={{ display: 'flex', gap: '24px' }}>
        <Anchor
            links={[
                { href: '#anchor-section-1', title: '第一节' },
                { href: '#anchor-section-2', title: '第二节' },
                { href: '#anchor-section-3', title: '第三节' },
            ]}
            getContainer={() => document.getElementById('anchor-scroll-container')!}
            aria-label="锚点导航"
        />
        <div id="anchor-scroll-container" style={{ width: '320px', height: '200px', overflowY: 'auto', border: '1px solid var(--lotus-color-border)', padding: '12px' }}>
            <div id="anchor-section-1" style={{ height: '220px' }}>第一节内容</div>
            <div id="anchor-section-2" style={{ height: '220px' }}>第二节内容</div>
            <div id="anchor-section-3" style={{ height: '220px' }}>第三节内容</div>
        </div>
    </div>
}
