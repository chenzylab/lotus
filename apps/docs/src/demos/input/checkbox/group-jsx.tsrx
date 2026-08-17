import { CheckboxGroup, Checkbox } from '@lotus/ripple';

export function CheckboxGroupJsxDemo() {
    return (
        <CheckboxGroup defaultValue={['b']} aria-label="JSX 方式">
            <Checkbox value="a">选项 A</Checkbox>
            <Checkbox value="b">选项 B</Checkbox>
            <Checkbox value="c" disabled>选项 C</Checkbox>
        </CheckboxGroup>
    );
}
