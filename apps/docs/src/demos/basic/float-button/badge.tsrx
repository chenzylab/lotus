import { FloatButton } from '@lotus/ripple';
import { IconSetting } from '@lotus/icons';

// FloatButton 默认 position: fixed（固定在视口右下角），文档展示场景下用
// style 覆盖为 position: relative 以便正常陈列，实际使用时不需要这样覆盖。
export function BadgeFloatButtonDemo() {
    return <FloatButton
        icon={<IconSetting />}
        badge={{ count: 5 }}
        aria-label="带角标的悬浮按钮"
        style={{ position: 'relative', right: 'auto', bottom: 'auto' }}
    />;
}
