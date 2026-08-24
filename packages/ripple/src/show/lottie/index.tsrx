import { track, effect, untrack } from 'ripple';
import lottie, { type AnimationItem } from 'lottie-web';
import { resolveLoadParams, type LottieLoadParams } from '@lotus/foundation/show/lottie';

export type { LottieLoadParams, AnimationItem };

export interface LottieProps {
    params: LottieLoadParams;
    width?: string;
    height?: string;
    class?: string;
    style?: Record<string, any>;
    getAnimationInstance?: (instance: AnimationItem | null) => void;
    getLottie?: (lottiePKG: typeof lottie) => void;
}

function paramsEqual(a: LottieLoadParams, b: LottieLoadParams): boolean {
    return JSON.stringify(a) === JSON.stringify(b);
}

export function Lottie(&{
    params,
    width,
    height,
    class: className,
    style,
    getAnimationInstance,
    getLottie,
}: LottieProps) @{
    let &[containerEl] = track<HTMLDivElement | null>(null);
    let animation: AnimationItem | null = null;
    let prevParams: LottieLoadParams | null = null;

    // 首次挂载：容器 ref 就绪后加载动画并回调交出真实实例（对齐 Cropper 的
    // getCropperApi"回调交出真实操作句柄"模式——Ripple 没有 ref 转发到自定义
    // 实例的机制）。containerEl 必须是响应式变量：ref 回调赋值发生在组件挂载
    // 之后，若用普通闭包变量，这个 effect() 在 containerEl 还是 null 时执行
    // 一次后就不会再重新触发，容器就绪后动画永远不会被加载。
    // params.container 存在时用用户自管的容器，不依赖组件自己渲染的 div。
    effect(() => {
        const container = params.container ?? containerEl;
        if (!container) return;
        if (animation) return;
        animation = lottie.loadAnimation(resolveLoadParams(container, params) as Parameters<typeof lottie.loadAnimation>[0]);
        prevParams = params;
        getAnimationInstance?.(animation);
        getLottie?.(lottie);

        return () => {
            animation?.destroy();
            animation = null;
        };
    });

    // params 变化时销毁旧实例、重新加载（对齐 Semi handleParamsUpdate）。
    effect(() => {
        const currentParams = params;
        const container = currentParams.container ?? untrack(() => containerEl);
        if (!container || !animation || !prevParams) return;
        if (paramsEqual(prevParams, currentParams)) return;
        animation.destroy();
        animation = lottie.loadAnimation(resolveLoadParams(container, currentParams) as Parameters<typeof lottie.loadAnimation>[0]);
        prevParams = currentParams;
        getAnimationInstance?.(animation);
    });

    @if (!params.container) {
        <div
            class={['lotus-lottie', className ?? ''].filter(Boolean).join(' ')}
            style={{
                ...(width !== undefined ? { width } : {}),
                ...(height !== undefined ? { height } : {}),
                ...style,
            }}
            ref={(node: HTMLDivElement | null) => { containerEl = node; }}
        />
    }
}
