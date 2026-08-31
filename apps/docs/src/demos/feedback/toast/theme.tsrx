import { Toast, Button, Space } from '@lotus/ripple';

export function ThemeToastDemo() @{
    <Space>
        <Button onClick={() => Toast.info({ content: 'theme=normal 默认纯色', theme: 'normal' })}>theme=normal</Button>
        <Button onClick={() => Toast.info({ content: 'theme=light 浅色填充样式', theme: 'light' })}>theme=light</Button>
        <Button onClick={() => Toast.info({ content: '这是一条超过最大宽度限制的提示文案，用于验证 textMaxWidth 生效', textMaxWidth: 200 })}>textMaxWidth=200</Button>
        <Button onClick={() => Toast.destroyAll()}>destroyAll</Button>
    </Space>
}
