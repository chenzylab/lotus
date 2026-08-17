import { Radio } from '@lotus/ripple';

export function RadioBasicDemo() {
    return <Radio defaultChecked onChange={(checked: boolean) => console.log('radio changed', checked)}>选项一</Radio>;
}
