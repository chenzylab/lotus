import { Button, TimePicker } from '@lotus/ripple';

export function TriggerRenderTimePickerDemo() @{
    <div style={{ width: '240px', display: 'flex', flexDirection: 'column', gap: '12px' }}>
        <TimePicker
            triggerRender={({ value, placeholder, open }) => (
                <Button>{value || placeholder}（{open ? '展开' : '收起'}）</Button>
            )}
        />
        <TimePicker zIndex={2000} stopPropagation dropdownMargin={8} />
    </div>
}
