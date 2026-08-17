import { InputNumber } from '@lotus/ripple';

export function InputNumberBoundaryDemo() {
    return <InputNumber min={0} max={100} defaultValue={50} step={5} aria-label="边界示例" />;
}
