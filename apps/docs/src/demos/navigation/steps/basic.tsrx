import { track } from 'ripple';
import { Steps, Button, Space } from '@lotus/ripple';

export function BasicStepsDemo() @{
    let &[current] = track<number>(0);

    <div>
        <Steps
            current={current}
            items={[
                { title: '第一步', description: '填写基本信息' },
                { title: '第二步', description: '确认订单' },
                { title: '第三步', description: '完成支付' },
                { title: '第四步', description: '交易完成' },
            ]}
            onChange={(c) => { current = c; }}
            aria-label="基础步骤条"
        />
        <Space style={{ marginTop: '12px' }}>
            <Button onClick={() => { current = Math.max(0, current - 1); }}>上一步</Button>
            <Button onClick={() => { current = Math.min(3, current + 1); }}>下一步</Button>
        </Space>
    </div>
}
