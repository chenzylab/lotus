import { track } from 'ripple';
import { TagInput } from '@lotus/ripple';

export function TagInputInsetLabelDemo() @{
    let &[value] = track<string[]>(['标签一']);

    <div style={{ width: '360px' }}>
        <TagInput
            value={value}
            onChange={(v) => { value = v; }}
            insetLabel="标签"
            insetLabelId="tag-input-inset-label-doc"
            aria-label="TagInput insetLabel"
        />
    </div>
}
