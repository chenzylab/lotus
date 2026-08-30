import { Spin } from '@lotus/ripple';

export function BasicSpinDemo() @{
    <div style={{ display: 'flex', gap: '24px', alignItems: 'center' }}>
        <Spin spinning size="small" aria-label="小尺寸 Spin" />
        <Spin spinning size="middle" aria-label="中尺寸 Spin" />
        <Spin spinning size="large" aria-label="大尺寸 Spin" />
    </div>
}
