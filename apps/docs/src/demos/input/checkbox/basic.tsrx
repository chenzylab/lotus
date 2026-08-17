import { Checkbox } from '@lotus/ripple';

export function CheckboxBasicDemo() {
    return <Checkbox defaultChecked onChange={(checked: boolean) => console.log('checkbox changed', checked)}>同意用户协议</Checkbox>;
}
