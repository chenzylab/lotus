import { Slider, Space } from '@lotus/ripple';

export function CustomizationSliderDemo() @{
    <Space vertical align="start">
        <div style={{ width: '320px' }}>
            <Slider defaultValue={30} handleDot={{ color: 'var(--lotus-color-danger)', size: '10px' }} aria-label="自定义手柄圆点" />
        </div>
        <div style={{ width: '320px' }}>
            <Slider defaultValue={30} showBoundary aria-label="显示边界值" />
        </div>
        <div style={{ width: '320px' }}>
            <Slider defaultValue={40} marks={{ 0: '0', 50: '50', 100: '100' }} tooltipOnMark aria-label="刻度点带 Tooltip" />
        </div>
    </Space>
}
