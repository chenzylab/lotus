import { Steps } from '@lotus/ripple';

export function VerticalErrorStepsDemo() @{
    <div style={{ maxWidth: '300px' }}>
        <Steps
            current={1}
            status="error"
            direction="vertical"
            items={[
                { title: '第一步', description: '已完成' },
                { title: '第二步', description: '出现错误' },
                { title: '第三步', description: '待处理' },
            ]}
            aria-label="垂直方向步骤条（错误态）"
        />
    </div>
}
