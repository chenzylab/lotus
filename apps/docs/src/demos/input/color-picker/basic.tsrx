import { track } from 'ripple';
import { ColorPicker, TypographyText } from '@lotus/ripple';

export function ColorPickerBasicDemo() @{
    let &[log] = track<string>('');

    <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
        <ColorPicker
            onChange={(v) => { log = `选中颜色：${v.hex}`; }}
            aria-label="基础拾色器"
        />
        <TypographyText type="secondary">{log}</TypographyText>
    </div>
}
