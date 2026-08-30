import { track } from 'ripple';
import { TagInput } from '@lotus/ripple';

export function FoldTagInputDemo() @{
    let &[value] = track<string[]>(['标签一', '标签二', '标签三', '标签四', '标签五']);

    <div style={{ width: '260px' }}>
        <TagInput
            value={value}
            onChange={(v) => { value = v; }}
            maxTagCount={3}
            aria-label="TagInput 折叠"
        />
    </div>
}
