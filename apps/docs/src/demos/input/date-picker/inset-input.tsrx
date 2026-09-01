import { DatePicker } from '@lotus/ripple';

export function DatePickerInsetInputDemo() @{
    <div style={{ display: 'flex', gap: '16px' }}>
        <div style={{ width: '260px' }}>
            <DatePicker insetInput aria-label="insetInput 基础示例" />
        </div>
        <div style={{ width: '320px' }}>
            <DatePicker type="dateRange" insetInput aria-label="insetInput 范围示例" />
        </div>
    </div>
}
