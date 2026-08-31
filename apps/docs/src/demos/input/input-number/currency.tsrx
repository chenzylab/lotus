import { InputNumber, Space } from '@lotus/ripple';

export function CurrencyInputNumberDemo() {
    return <Space vertical align="start">
        <InputNumber defaultValue={1234.5} currency="CNY" localeCode="zh-CN" style={{ width: '200px' }} />
        <InputNumber defaultValue={1234.5} currency="USD" localeCode="en-US" currencyDisplay="code" style={{ width: '200px' }} />
        <InputNumber defaultValue={1234.5} currency="EUR" localeCode="de-DE" showCurrencySymbol={false} style={{ width: '200px' }} />
    </Space>;
}
