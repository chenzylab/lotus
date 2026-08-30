import { Timeline } from '@lotus/ripple';

export function BasicTimelineDemo() @{
    <Timeline
        dataSource={[
            { content: '创建项目', time: '2026-01-01', type: 'success' },
            { content: '进行中', time: '2026-01-05', type: 'ongoing' },
            { content: '待处理', time: '2026-01-10' },
        ]}
        aria-label="基础 Timeline"
    />
}
