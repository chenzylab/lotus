import { FloatButton, Space } from '@lotus/ripple';
import { IconSetting, IconAiBellLevel3 } from '@lotus/icons';

// FloatButton 默认 position: fixed（固定在视口右下角），文档展示场景下用
// style 覆盖为 position: relative 以便并排陈列，实际使用时不需要这样覆盖。
export function BasicFloatButtonDemo() {
    return <Space>
        <FloatButton icon={<IconSetting />} aria-label="悬浮设置" style={{ position: 'relative', right: 'auto', bottom: 'auto' }} />
        <FloatButton icon={<IconAiBellLevel3 />} colorful aria-label="AI 悬浮按钮" style={{ position: 'relative', right: 'auto', bottom: 'auto' }} />
        <FloatButton icon={<IconSetting />} shape="square" aria-label="方形悬浮按钮" style={{ position: 'relative', right: 'auto', bottom: 'auto' }} />
        <FloatButton icon={<IconSetting />} size="small" aria-label="小号悬浮按钮" style={{ position: 'relative', right: 'auto', bottom: 'auto' }} />
        <FloatButton icon={<IconSetting />} disabled aria-label="禁用悬浮按钮" style={{ position: 'relative', right: 'auto', bottom: 'auto' }} />
    </Space>;
}
