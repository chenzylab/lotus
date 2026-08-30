import { track } from 'ripple';
import { UserGuide, Button, Space, TypographyText } from '@lotus/ripple';

export function PopupUserGuideDemo() @{
    let &[visible] = track<boolean>(false);
    let &[current] = track<number>(0);
    let &[log] = track<string>('');
    let stepAEl: HTMLElement | null = null;
    let stepBEl: HTMLElement | null = null;
    let stepCEl: HTMLElement | null = null;

    <div>
        <Space style={{ marginBottom: '16px' }}>
            <Button size="small" onClick={() => { visible = true; }}>开始引导</Button>
            <TypographyText>{log}</TypographyText>
        </Space>
        <Space style={{ gap: '24px' }}>
            <span ref={(node: HTMLElement) => { stepAEl = node; }}><Button theme="light">步骤一目标</Button></span>
            <span ref={(node: HTMLElement) => { stepBEl = node; }}><Button theme="light">步骤二目标</Button></span>
            <span ref={(node: HTMLElement) => { stepCEl = node; }}><Button theme="light">步骤三目标</Button></span>
        </Space>
        <UserGuide
            visible={visible}
            current={current}
            steps={[
                { target: () => stepAEl ?? null, title: '第一步', description: '这是第一个目标元素的说明文案。', position: 'bottom' },
                { target: () => stepBEl ?? null, title: '第二步', description: '这是第二个目标元素的说明文案，spotlightPadding 覆盖为 0。', position: 'bottom', spotlightPadding: 0 },
                { target: () => stepCEl ?? null, title: '第三步', description: '最后一步，点击完成结束引导。', position: 'top', theme: 'primary' },
            ]}
            onChange={(next) => { current = next; log = `onChange: ${next}`; }}
            onSkip={() => { log = 'onSkip'; visible = false; current = 0; }}
            onFinish={() => { log = 'onFinish'; visible = false; current = 0; }}
            aria-label="popup UserGuide"
        />
    </div>
}
