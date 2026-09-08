import { track } from 'ripple';
import { Steps } from '@lotus/ripple';

export function NavStepsDemo() @{
    let &[current] = track<number>(0);

    <Steps
        type="nav"
        current={current}
        items={[
            { title: '概览' },
            { title: '详情' },
            { title: '设置' },
        ]}
        onChange={(c) => { current = c; }}
        aria-label="nav 类型导航式步骤条"
    />
}
