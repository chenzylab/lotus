import { track } from 'ripple';
import { PinCode, TypographyText } from '@lotus/ripple';

export function PinCodeBasicDemo() @{
    let &[log] = track<string>('');

    <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
        <PinCode
            count={6}
            format="number"
            autoFocus={false}
            onComplete={(v: string) => { log = `输入完成：${v}`; }}
            aria-label="6 位数字验证码"
        />
        <TypographyText type="secondary">{log}</TypographyText>
    </div>
}
