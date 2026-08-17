import { RadioGroup, Radio } from '@lotus/ripple';

export function RadioGroupJsxDemo() {
    return (
        <RadioGroup defaultValue="b" aria-label="JSX 方式">
            <Radio value="a">选项 A</Radio>
            <Radio value="b">选项 B</Radio>
            <Radio value="c" disabled>选项 C</Radio>
        </RadioGroup>
    );
}
