import { JsonViewer } from '@lotus/ripple';

export function SizeJsonViewerDemo() @{
    <JsonViewer
        width={300}
        height={150}
        defaultExpandDepth={Infinity}
        value={{ a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7, h: 8 }}
    />
}
