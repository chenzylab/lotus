import { track } from 'ripple';
import { Sidebar, SidebarMCPConfigure, SidebarAnnotation, Button } from '@lotus/ripple';

export function SubComponentsSidebarDemo() @{
    let &[visible] = track<boolean>(false);

    <>
        <Button onClick={() => { visible = true; }}>打开含子组件的主视图</Button>

        <Sidebar
            visible={visible}
            mode="main"
            title="AI 助手"
            renderMainContent={() => (
                <div>
                    <SidebarMCPConfigure
                        options={[
                            { value: 'web-search', label: 'Web Search', desc: '联网搜索工具', active: true },
                            { value: 'calculator', label: 'Calculator', desc: '数值计算工具', active: false },
                        ]}
                        customOptions={[{ value: 'my-tool', label: '我的自定义工具', active: false, configure: true }]}
                    />
                    <SidebarAnnotation
                        info={[
                            {
                                key: 'group-1',
                                header: '参考资料',
                                annotations: [
                                    { type: 'text', title: 'lotus 组件库文档', detail: '对齐 Semi Design 的 tsrx 组件库', siteName: 'lotus docs', order: 1 },
                                ],
                            },
                        ]}
                    />
                </div>
            )}
            onCancel={() => { visible = false; }}
        />
    </>
}
