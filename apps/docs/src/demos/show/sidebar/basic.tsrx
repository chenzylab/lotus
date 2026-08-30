import { track } from 'ripple';
import { Sidebar, Button, Space } from '@lotus/ripple';

export function BasicSidebarDemo() @{
    let &[visible] = track<boolean>(false);
    let &[mode] = track<'main' | 'code'>('main');

    <>
        <Space>
            <Button onClick={() => { mode = 'main'; visible = true; }}>打开主视图</Button>
            <Button onClick={() => { mode = 'code'; visible = true; }}>打开详情视图</Button>
        </Space>

        <Sidebar
            visible={visible}
            mode={mode}
            title="AI 助手"
            options={[
                { key: 'mcp', name: 'MCP 工具配置' },
                { key: 'annotation', name: '引用溯源' },
            ]}
            renderMainContent={() => <div style={{ padding: '8px 0' }}>主视图内容区域</div>}
            renderDetailContent={() => <div style={{ padding: '8px 0' }}>详情视图内容区域</div>}
            onBackWard={() => { mode = 'main'; }}
            onCancel={() => { visible = false; }}
        />
    </>
}
