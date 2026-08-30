import { TimePicker } from '@lotus/ripple';

export function DisabledOptionsTimePickerDemo() {
    return (
        <div style={{ width: '240px' }}>
            <TimePicker
                disabledHours={() => [0, 1, 2, 3, 4, 5, 22, 23]}
                disabledMinutes={(h: number) => (h === 9 ? [0, 15, 30, 45] : [])}
                hideDisabledOptions
                aria-label="TimePicker 禁用项"
            />
        </div>
    );
}
