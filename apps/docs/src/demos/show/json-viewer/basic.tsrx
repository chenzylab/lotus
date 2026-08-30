import { JsonViewer } from '@lotus/ripple';

export function BasicJsonViewerDemo() @{
    <div style={{ width: '360px' }}>
        <JsonViewer
            value={{
                name: 'lotus',
                version: '0.0.0',
                keywords: ['ripple', 'tsrx', 'ui'],
                author: { name: '张三', age: 20 },
                homepage: null,
            }}
        />
    </div>
}
