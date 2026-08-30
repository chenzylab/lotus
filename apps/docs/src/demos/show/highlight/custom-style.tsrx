import { Highlight } from '@lotus/ripple';

export function CustomStyleHighlightDemo() @{
    <Highlight
        sourceString="不同关键词可以有各自独立的高亮样式"
        searchWords={[
            { text: '关键词', style: { color: '#fff', background: 'var(--lotus-color-danger)' } },
            { text: '独立', style: { color: '#fff', background: 'var(--lotus-color-success)' } },
        ]}
        component="strong"
        aria-label="自定义样式 Highlight"
    />
}
