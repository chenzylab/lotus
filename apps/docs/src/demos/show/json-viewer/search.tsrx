import { JsonViewer } from '@lotus/ripple';

export function SearchJsonViewerDemo() @{
    <div style={{ width: '360px' }}>
        <JsonViewer
            showSearch
            height={200}
            value={{
                users: [
                    { name: 'Alice', role: 'admin' },
                    { name: 'Bob', role: 'user' },
                    { name: 'Charlie', role: 'user' },
                ],
                total: 3,
            }}
        />
    </div>
}
