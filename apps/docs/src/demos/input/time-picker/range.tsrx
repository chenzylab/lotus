import { track } from 'ripple';
import { TimePicker, TypographyText } from '@lotus/ripple';

export function RangeTimePickerDemo() @{
    let &[log] = track<string>('');

    <div style={{ width: '320px' }}>
        <TimePicker
            type="timeRange"
            onChange={(v) => {
                const pair = v as [Date | null, Date | null];
                log = `变化：${pair[0]?.toLocaleTimeString() ?? 'null'} ~ ${pair[1]?.toLocaleTimeString() ?? 'null'}`;
            }}
            aria-label="TimePicker 范围"
        />
        <TypographyText type="secondary" aria-label="TimePicker 范围事件日志">{log}</TypographyText>
    </div>
}
