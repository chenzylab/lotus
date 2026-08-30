import { DatePicker } from '@lotus/ripple';

export function DatePickerTypeVariantsDemo() @{
    <div style={{ display: 'flex', gap: '16px' }}>
        <div style={{ width: '260px' }}>
            <DatePicker type="dateTime" aria-label="日期时间选择" />
        </div>
        <div style={{ width: '160px' }}>
            <DatePicker type="month" aria-label="月份选择" />
        </div>
        <div style={{ width: '160px' }}>
            <DatePicker type="year" aria-label="年份选择" />
        </div>
    </div>
}
