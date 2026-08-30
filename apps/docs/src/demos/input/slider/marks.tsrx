import { Slider } from '@lotus/ripple';

export function SliderMarksDemo() @{
    <div style={{ width: '320px' }}>
        <Slider
            step={10}
            marks={{ 0: '0°C', 50: '50°C', 100: '100°C' }}
            defaultValue={50}
            aria-label="带刻度滑块"
        />
    </div>
}
