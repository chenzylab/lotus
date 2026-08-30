import { track } from 'ripple';
import { HotKeys, TypographyText } from '@lotus/ripple';

export function ClickableHotKeysDemo() @{
    let &[log] = track<string>('');

    <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
        <HotKeys
            hotKeys={['control', 'k']}
            aria-label="打开命令面板"
            onClick={() => { log = '点击生效'; }}
        />
        <TypographyText type="secondary">{log}</TypographyText>
    </div>
}
