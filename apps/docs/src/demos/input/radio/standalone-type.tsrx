import { Radio, Space } from '@lotus/ripple';

export function RadioStandaloneTypeDemo() {
    return (
        <Space vertical align="start">
            <Radio name="radio-standalone-button-demo" type="button" aria-label="单独 type=button 示例">单独设置 type=button</Radio>
            <Radio name="radio-standalone-card-demo" type="card" aria-label="单独 type=card 示例">单独设置 type=card</Radio>
        </Space>
    );
}
