import { TextArea } from '@lotus/ripple';

export function TextAreaCountDemo() {
    return <TextArea placeholder="带字数统计与清除按钮" maxCount={50} showClear defaultValue="可清除且带字数统计" />;
}
