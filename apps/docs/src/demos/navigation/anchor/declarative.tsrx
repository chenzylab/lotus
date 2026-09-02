import { Anchor, AnchorLink } from '@lotus/ripple';

export function DeclarativeAnchorDemo() @{
    <div style={{ display: 'flex', gap: '24px' }}>
        <Anchor getContainer={() => document.getElementById('anchor-declarative-container')!} aria-label="锚点导航声明式">
            <AnchorLink href="#anchor-decl-1" title="一号" />
            <AnchorLink href="#anchor-decl-2" title="二号（禁用）" disabled />
            <AnchorLink href="#anchor-decl-3" title="三号" />
        </Anchor>
        <div id="anchor-declarative-container" style={{ width: '320px', height: '200px', overflowY: 'auto', border: '1px solid var(--lotus-color-border)', padding: '12px' }}>
            <div id="anchor-decl-1" style={{ height: '220px' }}>一号内容</div>
            <div id="anchor-decl-2" style={{ height: '220px' }}>二号内容</div>
            <div id="anchor-decl-3" style={{ height: '220px' }}>三号内容</div>
        </div>
    </div>
}
