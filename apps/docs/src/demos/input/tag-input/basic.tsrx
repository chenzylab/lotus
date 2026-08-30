import { track } from 'ripple';
import { TagInput, TypographyText } from '@lotus/ripple';

export function BasicTagInputDemo() @{
    let &[value] = track<string[]>(['ripple', 'tsrx']);
    let &[log] = track<string>('');

    <div style={{ width: '360px' }}>
        <TagInput
            value={value}
            onChange={(v) => { value = v; log = `变化：${v.join(',')}`; }}
            placeholder="输入后按 Enter 或逗号添加"
            aria-label="TagInput 基础"
        />
        <TypographyText type="secondary" aria-label="TagInput 事件日志">{log}</TypographyText>
    </div>
}
