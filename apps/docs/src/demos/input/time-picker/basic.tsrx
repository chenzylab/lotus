import { track } from 'ripple';
import { TimePicker, TypographyText } from '@lotus/ripple';

export function BasicTimePickerDemo() @{
    let &[log] = track<string>('');

    <div style={{ width: '240px' }}>
        <TimePicker
            onChange={(v) => { log = `变化：${v ? (v as Date).toLocaleTimeString() : 'null'}`; }}
            aria-label="TimePicker 基础"
        />
        <TypographyText type="secondary" aria-label="TimePicker 事件日志">{log}</TypographyText>
    </div>
}
