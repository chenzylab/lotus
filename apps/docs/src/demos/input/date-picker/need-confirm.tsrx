import { DatePicker } from '@lotus/ripple';

export function DatePickerNeedConfirmDemo() @{
    <div style={{ width: '260px' }}>
        <DatePicker
            type="dateTime"
            needConfirm
            onCancel={() => console.log('取消')}
            onConfirm={(value) => console.log('确认', value)}
            aria-label="需要确认的日期时间选择器"
        />
    </div>
}
