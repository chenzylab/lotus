/**
 * Lottie 的类型定义与 loadAnimation 入参组装纯函数。对齐 Semi Design
 * semi-foundation/lottie：Semi 的 Lottie 组件本身是 lottie-web 的极薄容器，
 * LottieBaseState 是空接口——没有内部状态机，唯一的逻辑是"给
 * lottie.loadAnimation 组装默认值 + 用户 params 覆盖"，因此本组件不需要
 * Foundation<S> 状态机基类，与 CodeHighlight（纯函数 resolveCodeClassName）
 * 同一惯例。
 *
 * 命令式播放控制（play/pause/stop/setSpeed/setDirection/goToAndStop 等）
 * 不由 lotus 自己封装：这是 Semi 与 chenzy.design 的共同设计决策——全部
 * 通过 getAnimationInstance 拿到的原生 AnimationItem 实例（自带这些方法）
 * 解决，组件层不重复包一层。
 */

export interface LottieLoadParams {
  path?: string;
  animationData?: unknown;
  renderer?: 'svg' | 'canvas' | 'html';
  loop?: boolean | number;
  autoplay?: boolean;
  name?: string;
  container?: Element;
  rendererSettings?: Record<string, unknown>;
  [key: string]: unknown;
}

/**
 * 组装 lottie.loadAnimation 的最终入参：默认 renderer='svg'、loop=true、
 * autoplay=true，用户 params 逐项覆盖（对齐 Semi getLoadParams），
 * container 由调用方（.tsrx 渲染层）显式传入真实 DOM 元素。
 */
export function resolveLoadParams(
  container: Element,
  params: Partial<LottieLoadParams>,
): LottieLoadParams {
  return {
    container,
    renderer: 'svg',
    loop: true,
    autoplay: true,
    ...params,
  };
}
