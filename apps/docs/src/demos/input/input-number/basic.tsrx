import { InputNumber } from '@lotus/ripple';

export function InputNumberBasicDemo() {
    return <InputNumber defaultValue={0} onChange={(value) => console.log('input number changed', value)} />;
}
