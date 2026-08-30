import { VideoPlayer } from '@lotus/ripple';

export function BasicVideoPlayerDemo() @{
    <div style={{ width: '480px' }}>
        <VideoPlayer src="/demo-video.mp4" width="100%" height="270px" />
    </div>
}
