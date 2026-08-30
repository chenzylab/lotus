import { track } from 'ripple';
import { Collapsible, Button } from '@lotus/ripple';

export function CollapseHeightCollapsibleDemo() @{
    let &[isOpen] = track<boolean>(false);

    <div>
        <Button onClick={() => { isOpen = !isOpen; }}>{isOpen ? '收起' : '展开更多'}</Button>
        <Collapsible isOpen={isOpen} collapseHeight={40} keepDOM aria-label="预览高度示例">
            <div style={{ padding: '12px', border: '1px solid var(--lotus-color-border)', marginTop: '8px' }}>
                <p>第一行内容始终露出一部分（collapseHeight=40），keepDOM 保证收起时内容仍在 DOM 中。</p>
                <p>第二行内容。</p>
                <p>第三行内容。</p>
            </div>
        </Collapsible>
    </div>
}
