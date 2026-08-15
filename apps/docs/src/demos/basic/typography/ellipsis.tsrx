import { TypographyText, TypographyParagraph, Space } from '@lotus/ripple';

export function TypographyEllipsisDemo() {
    return <Space vertical align="start">
        <div style={{ width: '240px' }}>
            <TypographyText
                ellipsis={{ showTooltip: true }}
                children="这是一段很长很长很长很长很长很长很长的文本，用于展示末尾省略并悬浮显示完整内容"
            />
        </div>
        <div style={{ width: '240px' }}>
            <TypographyText
                ellipsis={{ pos: 'middle' }}
                children="这是一段很长很长很长很长很长很长很长的文本，用于展示中间省略效果"
            />
        </div>
        <div style={{ width: '480px' }}>
            <TypographyParagraph
                ellipsis={{ rows: 2, expandable: true }}
                children="这是一段可展开收起的多行省略段落文本，默认只显示两行，点击展开按钮后可以看到完整内容，这段文本足够长以触发多行截断效果，用于验证 rows 与 expandable 组合使用时的表现。"
            />
        </div>
    </Space>;
}
