import { RadioGroup } from '@lotus/ripple';

export function RadioGroupOptionsDemo() {
    return (
        <RadioGroup
            options={[
                { value: 'a', label: '选项 A' },
                { value: 'b', label: '选项 B' },
                { value: 'c', label: '选项 C', disabled: true },
            ]}
            defaultValue="a"
            aria-label="options 数组方式"
            onChange={(value) => console.log('radio group changed', value)}
        />
    );
}
