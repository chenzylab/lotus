import { TextArea } from '@lotus/ripple';

export function AutosizeTextAreaDemo() {
    return <TextArea placeholder="输入内容后自动扩展高度（2-6 行）" autosize={{ minRows: 2, maxRows: 6 }} aria-label="TextArea 自适应高度" />;
}
