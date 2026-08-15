import { Input, Space } from '@lotus/ripple';

export function InputAffixDemo() {
    return <Space vertical align="start">
        <Input prefix="￥" suffix="RMB" placeholder="金额" />
        <Input showClear defaultValue="带清除按钮的文本内容" />
    </Space>;
}
