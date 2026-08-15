import { TextArea } from '@lotus/ripple';

export function TextAreaBasicDemo() {
    return <TextArea defaultValue="默认多行文本内容" rows={4} onChange={(value: string) => console.log('textarea changed', value)} />;
}
