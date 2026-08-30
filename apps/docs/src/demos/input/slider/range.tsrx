import { Slider } from '@lotus/ripple';

export function SliderRangeDemo() @{
    <div style={{ width: '320px' }}>
        <Slider range defaultValue={[20, 60]} aria-label="范围滑块" />
    </div>
}
