import { InputNumber } from '@lotus/ripple';

export function ScientificNotationInputNumberDemo() {
    return <InputNumber defaultValue={123456789012345} scientificNotation style={{ width: '220px' }} />;
}
