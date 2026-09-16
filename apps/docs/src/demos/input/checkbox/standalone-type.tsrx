import { Checkbox, Space } from '@lotus/ripple';

export function CheckboxStandaloneTypeDemo() {
    return (
        <Space>
            <Checkbox type="card" aria-label="单独 type=card 示例">单独设置 type=card</Checkbox>
            <Checkbox type="pureCard" aria-label="单独 type=pureCard 示例">单独设置 type=pureCard</Checkbox>
        </Space>
    );
}
