import { Timeline } from '@lotus/ripple';

export function AlternateTimelineDemo() @{
    <Timeline
        mode="alternate"
        dataSource={[
            { content: '左侧节点', time: '10:00', type: 'success' },
            { content: '右侧节点', time: '11:00', type: 'warning' },
            { content: '左侧节点', time: '12:00', type: 'error' },
        ]}
        aria-label="alternate 模式 Timeline"
    />
}
