import { track } from 'ripple';
import { JsonViewer } from '@lotus/ripple';

export function EditableJsonViewerDemo() @{
    let &[value] = track<unknown>({ name: 'lotus', version: '0.0.0', count: 42, active: true });

    <div style={{ width: '360px' }}>
        <JsonViewer
            editable
            defaultExpandDepth={Infinity}
            value={value}
            onChange={(next) => { value = next; }}
        />
    </div>
}
