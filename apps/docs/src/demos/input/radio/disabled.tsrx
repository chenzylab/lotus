import { Radio, Space } from '@lotus/ripple';

export function RadioDisabledDemo() {
    return (
        <Space>
            <Radio disabled>禁用未选中</Radio>
            <Radio disabled defaultChecked>禁用已选中</Radio>
        </Space>
    );
}
