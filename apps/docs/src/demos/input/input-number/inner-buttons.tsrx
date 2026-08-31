import { InputNumber, Space } from '@lotus/ripple';

export function InnerButtonsInputNumberDemo() {
    return <Space>
        <InputNumber defaultValue={0} innerButtons style={{ width: '160px' }} />
        <InputNumber defaultValue={0} pressTimeout={200} pressInterval={100} style={{ width: '160px' }} />
    </Space>;
}
