import { TextArea } from '@lotus/ripple';

export function LineNumberTextAreaDemo() {
    return (
        <TextArea
            showLineNumber
            rows={6}
            defaultValue={'第一行\n第二行较长内容用于测试自动换行时行号是否跟随视觉行对齐\n第三行'}
            aria-label="TextArea 行号栏"
        />
    );
}
