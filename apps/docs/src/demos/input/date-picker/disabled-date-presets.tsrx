import { DatePicker } from '@lotus/ripple';

export function DatePickerDisabledDatePresetsDemo() @{
    <div style={{ display: 'flex', gap: '16px' }}>
        <div style={{ width: '260px' }}>
            <DatePicker
                disabledDate={(d) => d.getDay() === 0 || d.getDay() === 6}
                aria-label="禁用周末的日期选择"
            />
        </div>
        <div style={{ width: '260px' }}>
            <DatePicker
                presets={[
                    { text: '今天', start: () => new Date() },
                    { text: '一周后', start: () => { const d = new Date(); d.setDate(d.getDate() + 7); return d; } },
                ]}
                aria-label="带快捷选项的日期选择"
            />
        </div>
    </div>
}
