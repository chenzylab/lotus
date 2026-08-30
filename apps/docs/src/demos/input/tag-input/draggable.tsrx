import { track } from 'ripple';
import { TagInput } from '@lotus/ripple';

export function DraggableTagInputDemo() @{
    let &[value] = track<string[]>(['A', 'B', 'C', 'D']);

    <div style={{ width: '360px' }}>
        <TagInput
            value={value}
            onChange={(v) => { value = v; }}
            draggable
            aria-label="TagInput 拖拽"
        />
    </div>
}
