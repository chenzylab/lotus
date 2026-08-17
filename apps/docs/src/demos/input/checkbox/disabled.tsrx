import { Checkbox, Space } from '@lotus/ripple';

export function CheckboxDisabledDemo() {
    return (
        <Space>
            <Checkbox disabled>禁用未选中</Checkbox>
            <Checkbox disabled defaultChecked>禁用已选中</Checkbox>
        </Space>
    );
}
