import { TextArea } from '@lotus/ripple';

export function CountClearTextAreaDemo() {
    return <TextArea placeholder="带字数统计与清除按钮" maxCount={50} showClear defaultValue="可清除且带字数统计" aria-label="TextArea 字数统计" />;
}
