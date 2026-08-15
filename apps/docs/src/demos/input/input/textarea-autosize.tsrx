import { TextArea } from '@lotus/ripple';

export function TextAreaAutosizeDemo() {
    return <TextArea placeholder="自动扩展高度，输入多行文字试试" autosize={{ minRows: 2, maxRows: 6 }} />;
}
