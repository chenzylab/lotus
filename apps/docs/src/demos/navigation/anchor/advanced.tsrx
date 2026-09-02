import { Anchor, AnchorLink } from '@lotus/ripple';

export function AdvancedAnchorDemo() @{
    <div style={{ display: 'flex', gap: '24px' }}>
        <Anchor
            getContainer={() => document.getElementById('anchor-advanced-container')!}
            autoCollapse
            showTooltip
            aria-label="锚点导航折叠"
        >
            <AnchorLink href="#anchor-adv-1" title="这是一个非常长的标题用于验证省略与 tooltip 展示效果">
                <AnchorLink href="#anchor-adv-1-1" title="子项 1-1" />
                <AnchorLink href="#anchor-adv-1-2" title="子项 1-2" />
            </AnchorLink>
            <AnchorLink href="#anchor-adv-2" title="第二节" />
        </Anchor>
        <div id="anchor-advanced-container" style={{ width: '320px', height: '200px', overflowY: 'auto', border: '1px solid var(--lotus-color-border)', padding: '12px' }}>
            <div id="anchor-adv-1" style={{ height: '150px' }}>第一节内容</div>
            <div id="anchor-adv-1-1" style={{ height: '150px' }}>子项 1-1 内容</div>
            <div id="anchor-adv-1-2" style={{ height: '150px' }}>子项 1-2 内容</div>
            <div id="anchor-adv-2" style={{ height: '150px' }}>第二节内容</div>
        </div>
    </div>
}
