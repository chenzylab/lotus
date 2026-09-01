import { track } from 'ripple';
import { TagInput, TypographyText } from '@lotus/ripple';

export function MaxLengthTagInputDemo() @{
    let &[log] = track<string>('');

    <div style={{ width: '360px' }}>
        <TagInput
            maxLength={4}
            onInputExceed={(v) => { log = `超限：${v}`; }}
            placeholder="单段最多 4 个字符"
            aria-label="TagInput maxLength 示例"
        />
        <TypographyText type="secondary" aria-label="TagInput maxLength 超限日志">{log}</TypographyText>
    </div>
}
