import { track } from 'ripple';
import { ConfigProvider, Button, Input, type ConfigProviderThemeMode } from '@lotus/ripple';

export function ModeConfigProviderDemo() @{
    let &[mode] = track<ConfigProviderThemeMode>('light');

    <ConfigProvider mode={mode}>
        <div style={{ padding: '16px', border: '1px solid var(--lotus-color-border)', borderRadius: 'var(--lotus-border-radius-medium)' }}>
            <Button onClick={() => { mode = mode === 'dark' ? 'light' : 'dark'; }}>
                {mode === 'dark' ? '切换到 light' : '切换到 dark'}
            </Button>
            <div style={{ marginTop: '12px' }}>
                <Input style={{ width: '200px' }} defaultValue="随主题切换" aria-label="ConfigProvider mode 示例 Input" />
            </div>
        </div>
    </ConfigProvider>
}
