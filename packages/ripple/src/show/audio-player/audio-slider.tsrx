import { track, effect, untrack } from 'ripple';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export interface AudioSliderProps {
    value: number;
    max: number;
    vertical?: boolean;
    'aria-label'?: string;
    onChange: (value: number) => void;
}

/**
 * AudioPlayer 专用的自建滑块（进度条/音量条共用），不复用通用 Slider——
 * 对齐 Semi 自建 AudioSlider 的既有设计（Semi 源码 semi-ui/audioPlayer/
 * audioSlider.tsx 明确不用通用 Slider 组件，chenzy.design 移植时同样自建），
 * 因为通用 Slider 的 range/marks/键盘导航机制在这里都用不上，属于不必要的
 * 复杂度。支持点击轨道任意位置直接跳转、按住拖拽跟手。
 */
export function AudioSlider(&{ value, max, vertical = false, 'aria-label': ariaLabel, onChange }: AudioSliderProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    let trackEl: HTMLElement | null = null;
    let dragging = false;

    function ratioFromEvent(event: MouseEvent): number {
        const el = untrack(() => trackEl);
        if (!el) return 0;
        const rect = el.getBoundingClientRect();
        // 水平模式下，值增大的方向要跟随内容流方向镜像（对齐 Semi Slider 在
        // RTL 下的真实实现——isRTL 时交换起止锚点，往右拖动变成减小而非增大）；
        // 垂直模式跟文字水平方向无关，永远从下往上增大，不受 dir 影响。
        const isRtlHorizontal = !vertical && untrack(() => locale).dir === 'rtl';
        const horizontalRatio = isRtlHorizontal
            ? 1 - (event.clientX - rect.left) / rect.width
            : (event.clientX - rect.left) / rect.width;
        const ratio = vertical
            ? 1 - (event.clientY - rect.top) / rect.height
            : horizontalRatio;
        return Math.min(1, Math.max(0, ratio));
    }

    function handleMouseDown(event: MouseEvent) {
        dragging = true;
        onChange(ratioFromEvent(event) * max);
    }

    effect(() => {
        const handleMouseMove = (event: MouseEvent) => {
            if (!dragging) return;
            onChange(ratioFromEvent(event) * max);
        };
        const handleMouseUp = () => {
            dragging = false;
        };
        document.addEventListener('mousemove', handleMouseMove);
        document.addEventListener('mouseup', handleMouseUp);
        return () => {
            document.removeEventListener('mousemove', handleMouseMove);
            document.removeEventListener('mouseup', handleMouseUp);
        };
    });

    let &[percent] = track<number>(() => (max > 0 ? Math.min(100, Math.max(0, (value / max) * 100)) : 0));
    let &[fillStyle] = track<{ width: string; height: string }>(() =>
        vertical ? { width: '', height: `${percent}%` } : { width: `${percent}%`, height: '' },
    );

    <>
    <div
        class={['lotus-audio-slider', vertical ? 'lotus-audio-slider-vertical' : 'lotus-audio-slider-horizontal'].join(' ')}
        role="slider"
        aria-label={ariaLabel}
        aria-valuemin={0}
        aria-valuemax={max}
        aria-valuenow={value}
        tabIndex={0}
        ref={(node: HTMLElement | null) => { trackEl = node; }}
        onMouseDown={handleMouseDown}
    >
        <div class="lotus-audio-slider-track">
            <div class="lotus-audio-slider-fill" style={fillStyle} />
        </div>
    </div>

    <style>
        .lotus-audio-slider {
            position: relative;
            cursor: pointer;
            display: flex;
        }

        .lotus-audio-slider-horizontal {
            width: 100%;
            height: 12px;
            align-items: center;
        }

        .lotus-audio-slider-vertical {
            width: 12px;
            height: 100%;
            justify-content: center;
        }

        .lotus-audio-slider-track {
            position: relative;
            background: var(--lotus-color-fill-1);
            border-radius: var(--lotus-border-radius-full);
            overflow: hidden;
        }

        .lotus-audio-slider-horizontal .lotus-audio-slider-track {
            width: 100%;
            height: 4px;
        }

        .lotus-audio-slider-vertical .lotus-audio-slider-track {
            width: 4px;
            height: 100%;
        }

        .lotus-audio-slider-fill {
            position: absolute;
            background: var(--lotus-color-primary);
            border-radius: var(--lotus-border-radius-full);
        }

        .lotus-audio-slider-horizontal .lotus-audio-slider-fill {
            inset-inline-start: 0;
            top: 0;
            height: 100%;
        }

        .lotus-audio-slider-vertical .lotus-audio-slider-fill {
            left: 0;
            bottom: 0;
            width: 100%;
        }
    </style>
    </>
}
