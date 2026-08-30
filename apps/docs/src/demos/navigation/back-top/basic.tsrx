import { BackTop } from '@lotus/ripple';

/**
 * `target` 支持自定义滚动容器（不仅限于监听 window），这里用一个有限高度的
 * 容器演示，方便在文档预览框内完整展示"滚动超过阈值后出现回顶按钮"的效果
 * ——若使用默认的 window 滚动，效果会发生在整个页面级别，无法在预览框内演示。
 */
export function BasicBackTopDemo() @{
    <div id="back-top-scroll-container" style={{ position: 'relative', width: '100%', height: '200px', overflowY: 'auto', border: '1px solid var(--lotus-color-border)' }}>
        <div style={{ height: '600px', padding: '12px' }}>
            向下滚动此区域超过 100px 后，右下角会出现回到顶部按钮。
        </div>
        <BackTop
            target={() => document.getElementById('back-top-scroll-container')!}
            visibilityHeight={100}
            style={{ position: 'absolute' }}
            aria-label="回到顶部"
        />
    </div>
}
