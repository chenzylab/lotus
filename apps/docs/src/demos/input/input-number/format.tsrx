import { InputNumber, Space } from '@lotus/ripple';

export function FormatInputNumberDemo() {
    return <Space vertical align="start">
        <InputNumber
            defaultValue={1000}
            formatter={(v) => `${v}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')}
            parser={(s) => s.replace(/,/g, '')}
            style={{ width: '200px' }}
        />
        <InputNumber defaultValue={1.2345} precision={2} step={0.1} style={{ width: '200px' }} />
        <InputNumber defaultValue={0} step={1} shiftStep={20} style={{ width: '200px' }} />
    </Space>;
}
