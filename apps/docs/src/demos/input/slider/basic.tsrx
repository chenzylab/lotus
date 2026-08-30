import { track } from 'ripple';
import { Slider, TypographyText } from '@lotus/ripple';

export function SliderBasicDemo() @{
    let &[log] = track<string>('');

    <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', width: '320px' }}>
        <Slider
            defaultValue={30}
            onChange={(v) => { log = `值变为 ${v}`; }}
            aria-label="基础滑块"
        />
        <TypographyText type="secondary">{log}</TypographyText>
    </div>
}
