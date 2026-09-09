import { track } from 'ripple';
import { ConfigProvider, Select, TimePicker } from '@lotus/ripple';

const TIME_ZONE_OPTIONS = Array.from({ length: 26 }, (_v, i) => {
    const hourOffset = i - 11;
    const sign = hourOffset >= 0 ? '+' : '-';
    const hh = String(Math.abs(hourOffset)).padStart(2, '0');
    return `GMT${sign}${hh}:00`;
});

export function TimeZoneConfigProviderDemo() @{
    let &[timeZone] = track<string>('GMT+08:00');

    <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', width: '320px' }}>
        <Select
            aria-label="选择时区"
            value={timeZone}
            optionList={TIME_ZONE_OPTIONS.map((tz) => ({ value: tz, label: tz }))}
            onChange={(v) => { timeZone = v as string; }}
        />
        <ConfigProvider timeZone={timeZone}>
            <TimePicker
                aria-label="ConfigProvider timeZone 示例"
                defaultValue={new Date('2026-01-01T12:00:00.000Z')}
                onChange={(v) => console.log('timeZone changed', v)}
            />
        </ConfigProvider>
    </div>
}
