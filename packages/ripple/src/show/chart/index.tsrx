import { track, effect, untrack } from 'ripple';
import { VChart, type ISpec } from '@visactor/vchart';
import {
    resolveChartSpec,
    isChartDataEmpty,
    type ChartProps as FoundationChartProps,
    type ChartType,
    type ChartEventParams,
} from '@lotus/foundation/show/chart';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';
import { IconDownloadStroked } from '@lotus/icons';
import { ensureLotusChartTheme } from './theme.js';
import { Spin } from '../../feedback/spin/index.tsrx';
import { Empty } from '../empty/index.tsrx';
import { IconButton } from '../../basic/icon-button/index.tsrx';

export type { ChartType, ChartEventParams };

export interface ChartProps extends FoundationChartProps {
    width?: string;
    height?: string;
    class?: string;
    style?: Record<string, any>;
    /** 加载中：整个图表区域覆盖 Spin 蒙层，不销毁已有的 VChart 实例（对齐
     * Table/List 组件已有的 loading 语义——数据刷新期间旧图表仍在原地，不会
     * 出现"loading 结束的瞬间图表整个重新创建、动画重放"这种体验倒退）。 */
    loading?: boolean;
    /** data 为空（所有数据系列的 values 都是空数组）时展示的占位内容；不传
     * 时用 Empty 组件 + locale 默认文案兜底，传入后完全交给消费方自定义
     * （对齐 Table 组件 `empty` prop 的既有覆盖模式）。 */
    empty?: any;
    /** 是否展示右上角导出图片按钮，默认不展示——多数图表场景不需要，强制
     * 常驻只会占用视觉空间。 */
    showExportButton?: boolean;
    /** 导出图片时的文件名（不含扩展名），默认 'chart'。 */
    exportFileName?: string;
    onExport?: () => void;
    /** 点击/悬浮图表内数据点时的回调，只透传业务方能直接消费的 `datum`/
     * `event` 两个字段（详见 Foundation 层 `ChartEventParams` 的注释）。 */
    onClick?: (params: ChartEventParams) => void;
    onHover?: (params: ChartEventParams) => void;
    'aria-label'?: string;
    getChartInstance?: (instance: VChart | null) => void;
}

function specEqual(a: Record<string, unknown>, b: Record<string, unknown>): boolean {
    return JSON.stringify(a) === JSON.stringify(b);
}

function toChartEventParams(raw: { datum?: unknown; event?: unknown }): ChartEventParams {
    return {
        datum: raw.datum as Record<string, unknown> | undefined,
        event: raw.event as Event | undefined,
    };
}

/**
 * Chart 图表。对齐调研结论——Semi 官方没有 Chart 组件源码可移植（"Semi DV"
 * 是闭源 SaaS 生成的 VChart 主题包，业务代码直接用 VChart 原生 spec API），
 * lotus 走"包一层 VChart + 移植其主题层实现方式"的路线：图表渲染完全交给
 * `@visactor/vchart`，lotus 只做 spec 组装（Foundation 层纯函数）与 lotus
 * Token → VChart 主题的映射（`./theme.ts`）。
 *
 * 生命周期管理照抄 Lottie 的既有模式（容器 ref + effect 挂载/销毁 + 命令式
 * 实例通过回调交出）——VChart 与 lottie-web 同属"自己管理实例生命周期的
 * 第三方库"，构造/更新/销毁的三段式结构完全一致，只是方法名不同
 * （loadAnimation/destroy 对 new VChart()/release()）。
 */
export function Chart(&{
    type,
    data,
    spec,
    width,
    height,
    class: className,
    style,
    loading = false,
    empty,
    showExportButton = false,
    exportFileName = 'chart',
    onExport,
    onClick,
    onHover,
    'aria-label': ariaLabel,
    getChartInstance,
}: ChartProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    let &[containerEl] = track<HTMLDivElement | null>(null);
    let chart: VChart | null = null;
    let prevSpec: Record<string, unknown> | null = null;

    // data 为空时不创建 VChart 实例，改渲染 Empty 占位——VChart 没有内建的
    // 空数据展示机制，渲染一个内容空白的图表画布对用户没有意义。
    let &[isEmpty] = track<boolean>(() => isChartDataEmpty(data));

    // 首次挂载：容器 ref 就绪后创建实例。containerEl 必须是响应式变量，理由
    // 与 Lottie 完全一致——ref 回调赋值发生在挂载之后，若用普通闭包变量，
    // 这个 effect() 会在 containerEl 还是 null 时执行一次后就不再重新触发，
    // 容器就绪后图表永远不会被创建。isEmpty 时 @if 条件不渲染容器元素，
    // containerEl 会是 null，这里的守卫自然覆盖了"空数据不建实例"的场景。
    effect(() => {
        const container = untrack(() => containerEl);
        if (!container) return;
        if (chart) return;
        const resolvedSpec = resolveChartSpec({ type, data, spec });
        // 不在构造 options 里传 theme：VChart 的 _updateCurrentTheme 内部一旦
        // 发现 this._option.theme 非空，后续每次主题切换都会用这个挂载时固化的
        // 旧主题名去 mergeTheme 覆盖新主题（options.theme 的合并优先级最高），
        // 导致 setCurrentThemeSync 之后视觉完全不变——真机验证暗色模式切换时
        // 发现的真实 bug（canvas 背景色在切换后仍是挂载时的旧值）。构造时不传
        // theme，构造完成后立即调用 setCurrentThemeSync 应用初始主题，让
        // options.theme 保持为空，后续切换才能走到"直接用 currentThemeName 取值"
        // 的正确分支。
        chart = new VChart(resolvedSpec as unknown as ISpec, { dom: container });
        chart.setCurrentThemeSync(ensureLotusChartTheme());
        if (onClick) chart.on('click', (params) => onClick(toChartEventParams(params)));
        if (onHover) chart.on('mouseenter', (params) => onHover(toChartEventParams(params)));
        chart.renderSync();
        prevSpec = resolvedSpec;
        getChartInstance?.(chart);

        return () => {
            chart?.release();
            chart = null;
        };
    });

    // type/data/spec 任一变化时用 updateSpecSync 整体替换（不做增量 diff——
    // VChart 自己的 updateSpecSync 内部已经做了 spec 级别的差异比对与最小化
    // 重绘，lotus 重复实现一层"哪个字段变了"的判断只会引入不一致的风险）。
    effect(() => {
        const resolvedSpec = resolveChartSpec({ type, data, spec });
        if (!chart || !prevSpec) return;
        if (specEqual(prevSpec, resolvedSpec)) return;
        chart.updateSpecSync(resolvedSpec as unknown as ISpec, true);
        prevSpec = resolvedSpec;
    });

    // ConfigProvider.mode 写入/移除 documentElement 的 data-theme 属性是
    // 组件挂载后可能随时发生的全局状态变化（不是构造时固定一次的配置），
    // 因此这里不能像 min/max 那类 Foundation opts 一样只在挂载时求值一次
    // ——同类教训见 RTL 支持时 Slider Foundation opts 的响应式盲区
    // （specs/cross-cutting/foundation-adapter-pattern.md 踩坑 #98）。
    // VChart 本身没有暴露"主题变化"的响应式钩子，用 MutationObserver 监听
    // documentElement 的 attribute 变化（对齐 `@visactor/vchart-theme-utils`
    // 的 `observeAttribute` 实现思路，但监听目标换成 documentElement 以对齐
    // lotus 自己的 mode 挂载点，而不是该库硬编码的 document.body）。
    effect(() => {
        if (typeof document === 'undefined' || typeof MutationObserver === 'undefined') return;
        const observer = new MutationObserver(() => {
            if (!chart) return;
            chart.setCurrentThemeSync(ensureLotusChartTheme());
        });
        observer.observe(document.documentElement, { attributes: true, attributeFilter: ['data-theme'] });
        return () => observer.disconnect();
    });

    async function handleExport() {
        if (!chart) return;
        await chart.exportImg(exportFileName);
        onExport?.();
    }

    <>
        <div class={['lotus-chart-wrapper', className ?? ''].filter(Boolean).join(' ')} style={{ position: 'relative', ...(width !== undefined ? { width } : {}), ...(height !== undefined ? { height } : {}), ...style }}>
            <Spin spinning={loading} style={{ width: '100%', height: '100%' }} childStyle={{ width: '100%', height: '100%' }}>
                @if (isEmpty) {
                    <div class="lotus-chart-empty" role="img" aria-label={ariaLabel ?? locale.Chart.emptyTitle}>
                        {empty ?? <Empty title={locale.Chart.emptyTitle} />}
                    </div>
                } @else {
                    <div
                        class="lotus-chart"
                        role="img"
                        aria-label={ariaLabel}
                        ref={(node: HTMLDivElement | null) => { containerEl = node; }}
                    />
                }
                @if (showExportButton && !isEmpty) {
                    <div class="lotus-chart-export">
                        <IconButton
                            icon={<IconDownloadStroked />}
                            size="small"
                            theme="borderless"
                            aria-label={locale.Chart.exportImage}
                            onClick={handleExport}
                        />
                    </div>
                }
            </Spin>
        </div>
        <style>
            /* VChart 内部用 ResizeObserver 监听容器尺寸自动 resize：一旦容器处于
             * CSS Grid/Flex 的 1fr / flex:1 轨道内，浏览器默认给这类轨道
             * min-width:auto，子元素（VChart 写入的 canvas 内联宽度）的固有尺寸
             * 会反过来撑大轨道本身，形成"canvas 撑大容器 → 容器变大触发
             * ResizeObserver → VChart 又把 canvas 设置得更宽"的正反馈循环
             * （真机验证时在 3 列 grid 布局下实测复现，canvas 内联宽度被撑到
             * 6000px+）。overflow:hidden 阻断"子元素固有尺寸影响父容器测量结果"
             * 这条链路，是这类"自身监听并回写尺寸"的第三方库场景下的必要防御，
             * 不能指望消费方每次使用都记得手动加。 */
            .lotus-chart-wrapper,
            .lotus-chart {
                overflow: hidden;
                min-width: 0;
                width: 100%;
                height: 100%;
            }

            .lotus-chart-empty {
                display: flex;
                align-items: center;
                justify-content: center;
                width: 100%;
                height: 100%;
                min-height: 160px;
            }

            .lotus-chart-export {
                position: absolute;
                top: 8px;
                right: 8px;
            }
        </style>
    </>
}
