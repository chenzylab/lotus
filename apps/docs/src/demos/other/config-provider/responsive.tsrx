import { track, effect } from 'ripple';
import { ConfigProvider, ConfigContext, type BreakpointScreens } from '@lotus/ripple';

function BreakpointWatcher() @{
    const configTracked = ConfigContext.get();
    let &[screens] = track<BreakpointScreens | null>(null);

    effect(() => {
        const onBreakpoint = configTracked?.value.onBreakpoint;
        if (!onBreakpoint) return;
        return onBreakpoint((next) => { screens = next; });
    });

    <div>
        <p style={{ margin: '0 0 8px', color: 'var(--lotus-color-text-secondary)' }}>
            缩放浏览器窗口查看当前命中的断点：
        </p>
        <pre style={{ margin: 0 }}>{JSON.stringify(screens, null, 2)}</pre>
    </div>
}

export function ResponsiveConfigProviderDemo() @{
    <ConfigProvider responsiveObserve>
        <div style={{ padding: '16px', border: '1px solid var(--lotus-color-border)', borderRadius: 'var(--lotus-border-radius-medium)' }}>
            <BreakpointWatcher />
        </div>
    </ConfigProvider>
}
