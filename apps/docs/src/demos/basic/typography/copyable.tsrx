import { TypographyText, Space } from '@lotus/ripple';

export function TypographyCopyableDemo() {
    return <Space vertical align="start">
        <TypographyText copyable children="点击右侧图标可复制这段默认文本" />
        <TypographyText
            copyable={{
                content: '自定义复制内容，与展示文本不同',
                onCopy: () => console.log('typography text copied'),
            }}
            children="展示的文本与实际复制的内容不同"
        />
    </Space>;
}
