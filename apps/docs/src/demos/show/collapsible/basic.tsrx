import { track } from 'ripple';
import { Collapsible, Button } from '@lotus/ripple';

export function BasicCollapsibleDemo() @{
    let &[isOpen] = track<boolean>(false);

    <div>
        <Button onClick={() => { isOpen = !isOpen; }}>{isOpen ? '收起' : '展开'}</Button>
        <Collapsible isOpen={isOpen} aria-label="Collapsible 示例内容">
            <div style={{ padding: '12px', border: '1px solid var(--lotus-color-border)', marginTop: '8px' }}>
                这是一个无头（headless）展开收起容器，触发器由使用方自己实现。
            </div>
        </Collapsible>
    </div>
}
