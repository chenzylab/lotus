import { track } from 'ripple';
import { HotKeys, TypographyText } from '@lotus/ripple';

export function BasicHotKeysDemo() @{
    let &[triggerCount] = track<number>(0);

    <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
        <span>按下</span>
        <HotKeys
            hotKeys={['control', 's']}
            preventDefault={true}
            onHotKey={() => { triggerCount = triggerCount + 1; }}
        />
        <TypographyText type="secondary">触发次数：{triggerCount}</TypographyText>
    </div>
}
