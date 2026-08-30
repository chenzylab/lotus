import { JsonViewer } from '@lotus/ripple';

export function ExpandDepthJsonViewerDemo() @{
    <div style={{ width: '360px' }}>
        <JsonViewer defaultExpandDepth={Infinity} showCopy={false} value={{ a: { b: { c: [1, 2, 3] } } }} />
    </div>
}
