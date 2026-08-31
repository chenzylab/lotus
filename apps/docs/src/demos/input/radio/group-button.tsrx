import { RadioGroup, Radio, Space } from '@lotus/ripple';

export function RadioGroupButtonDemo() {
    return (
        <Space vertical align="start">
            <RadioGroup type="button" buttonSize="small" defaultValue="a" aria-label="RadioGroup button small 示例">
                <Radio value="a">A</Radio>
                <Radio value="b">B</Radio>
                <Radio value="c" disabled>C</Radio>
            </RadioGroup>
            <RadioGroup type="button" buttonSize="middle" defaultValue="a" aria-label="RadioGroup button middle 示例">
                <Radio value="a">A</Radio>
                <Radio value="b">B</Radio>
                <Radio value="c" disabled>C</Radio>
            </RadioGroup>
            <RadioGroup type="button" buttonSize="large" defaultValue="a" aria-label="RadioGroup button large 示例">
                <Radio value="a">A</Radio>
                <Radio value="b">B</Radio>
                <Radio value="c" disabled>C</Radio>
            </RadioGroup>
        </Space>
    );
}
