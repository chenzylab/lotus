import { Highlight } from '@lotus/ripple';

export function BasicHighlightDemo() @{
    <Highlight
        sourceString="lotus 组件库支持关键词高亮，帮助用户快速定位搜索结果"
        searchWords={['lotus', '高亮']}
        aria-label="基础 Highlight"
    />
}
