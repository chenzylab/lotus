import { track } from 'ripple';
import { DatePicker, TypographyText } from '@lotus/ripple';

export function DatePickerBasicDemo() @{
    let &[log] = track<string>('');

    <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', width: '260px' }}>
        <DatePicker
            onChange={(v) => { log = `变化：${v ? (v as Date).toDateString() : 'null'}`; }}
            aria-label="基础日期选择"
        />
        <TypographyText type="secondary">{log}</TypographyText>
    </div>
}
