import { PinCode, Button, Space } from '@lotus/ripple';
import type { PinCodeApi } from '@lotus/ripple';

export function PinCodeApiDemo() @{
    let pinCodeApiRef: PinCodeApi | null = null;

    <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
        <PinCode
            count={4}
            autoFocus={false}
            getPinCodeApi={(api: PinCodeApi) => { pinCodeApiRef = api; }}
            aria-label="命令式聚焦示例"
        />
        <Space>
            <Button onClick={() => pinCodeApiRef?.focus(2)}>聚焦第 3 格</Button>
            <Button onClick={() => pinCodeApiRef?.blur(2)}>失焦第 3 格</Button>
        </Space>
    </div>
}
