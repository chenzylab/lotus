import { track } from 'ripple';
import { Lottie, Button, Space, type AnimationItem } from '@lotus/ripple';

export function BasicLottieDemo() @{
    let instance: AnimationItem | null = null;

    <div>
        <div style={{ width: '160px', height: '160px', border: '1px solid var(--lotus-color-border)' }}>
            <Lottie
                params={{ path: '/demo-lottie.json' }}
                width="160px"
                height="160px"
                getAnimationInstance={(inst) => { instance = inst; }}
            />
        </div>
        <Space style={{ marginTop: '8px' }}>
            <Button onClick={() => instance?.play()}>播放</Button>
            <Button onClick={() => instance?.pause()}>暂停</Button>
            <Button onClick={() => instance?.stop()}>停止</Button>
        </Space>
    </div>
}
