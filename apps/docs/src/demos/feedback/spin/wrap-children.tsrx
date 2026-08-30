import { track } from 'ripple';
import { Spin, Button } from '@lotus/ripple';

export function WrapChildrenSpinDemo() @{
    let &[spinning] = track<boolean>(true);

    <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', alignItems: 'flex-start' }}>
        <Spin spinning={spinning} aria-label="包裹内容的 Spin">
            <div style={{ width: '200px', height: '100px', border: '1px solid var(--lotus-color-border)', padding: '12px' }}>
                被包裹的内容区域
            </div>
        </Spin>
        <Button onClick={() => { spinning = !spinning; }}>切换加载态</Button>
    </div>
}
