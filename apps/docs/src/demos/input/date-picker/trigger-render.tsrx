import { DatePicker, Button } from '@lotus/ripple';

export function DatePickerTriggerRenderDemo() @{
    <DatePicker
        triggerRender={({ open }) => <Button>{open ? '收起日历' : '打开日历'}</Button>}
        aria-label="自定义触发器的日期选择器"
    />
}
