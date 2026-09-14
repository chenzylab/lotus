import { DatePicker } from '@lotus/ripple';

export function DatePickerOffsetDemo() @{
    <div style={{ width: '320px' }}>
        <DatePicker
            type="dateRange"
            startDateOffset={(d) => { const r = new Date(d); r.setDate(r.getDate() - r.getDay()); return r; }}
            endDateOffset={(d) => { const r = new Date(d); r.setDate(r.getDate() + (6 - r.getDay())); return r; }}
            aria-label="按周选择"
        />
    </div>
}
