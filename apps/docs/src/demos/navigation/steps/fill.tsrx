import { Steps } from '@lotus/ripple';

export function FillStepsDemo() @{
    <Steps
        type="fill"
        current={1}
        items={[
            { title: '第一步' },
            { title: '第二步' },
            { title: '第三步' },
        ]}
        aria-label="fill 类型步骤条"
    />
}
