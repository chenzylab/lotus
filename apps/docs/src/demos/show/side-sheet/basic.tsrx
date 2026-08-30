import { track } from 'ripple';
import { SideSheet, Button, Space, TypographyText } from '@lotus/ripple';

export function BasicSideSheetDemo() @{
    let &[visible] = track<boolean>(false);

    <div>
        <Button onClick={() => { visible = true; }}>打开右侧 SideSheet</Button>
        <SideSheet
            visible={visible}
            title="右侧 SideSheet"
            onCancel={() => { visible = false; }}
            footer={
                <Space>
                    <Button theme="light" type="tertiary" onClick={() => { visible = false; }}>取消</Button>
                    <Button theme="solid" type="primary" onClick={() => { visible = false; }}>确定</Button>
                </Space>
            }
            aria-label="右侧 SideSheet"
        >
            <TypographyText>这是 SideSheet 的内容区域。</TypographyText>
        </SideSheet>
    </div>
}
