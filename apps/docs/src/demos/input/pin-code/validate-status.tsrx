import { PinCode } from '@lotus/ripple';

export function PinCodeValidateStatusDemo() @{
    <div style={{ display: 'flex', gap: '16px' }}>
        <PinCode size="large" validateStatus="error" defaultValue="12" autoFocus={false} aria-label="错误态验证码" />
        <PinCode disabled defaultValue="1234" autoFocus={false} aria-label="禁用验证码" />
    </div>
}
