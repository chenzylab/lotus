import { AudioPlayer } from '@lotus/ripple';

export function PlaylistAudioPlayerDemo() @{
    <div style={{ width: '360px' }}>
        <AudioPlayer
            theme="light"
            audioUrl={[
                { src: '/demo-track-1.mp3', title: '演示曲目一' },
                { src: '/demo-track-2.mp3', title: '演示曲目二' },
            ]}
        />
    </div>
}
