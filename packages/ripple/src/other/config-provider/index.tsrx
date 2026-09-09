import { track, effect } from 'ripple';
import { zhCN, type LocaleShape } from '@lotus/locale';
import {
    DEFAULT_RESPONSIVE_MAP,
    createEmptyBreakpointScreens,
    readBreakpointScreens,
    watchAllBreakpoints,
    type ResponsiveMap,
    type ResponsiveBreakpoint,
    type BreakpointScreens,
} from '@lotus/foundation/base/responsive';
import { LocaleContext } from './locale-context.js';
import { ConfigContext, type ConfigContextValue } from './config-context.js';

export type ConfigProviderThemeMode = 'light' | 'dark';

export interface ConfigProviderProps {
    /** 子树内所有组件消费的语言包，默认中文简体。切换该 prop 会让子树内
     * 组件的文案（包括 Form 校验错误信息）实时更新，不需要重新挂载——
     * 因为文案读取走响应式 Context，不是挂载时读取一次的静态值。 */
    locale?: LocaleShape;
    /** 亮/暗主题模式。lotus 的 CSS 变量走 `:root[data-theme="dark"]` 选择器
     * 批量切换整套语义色（对齐 `packages/tokens` 构建产物，不是 Semi 的
     * `body[theme-mode]` 属性名——两者选择器不同，不能混用）；未传时不写入
     * `data-theme` 属性，交给页面自己决定（如 `prefers-color-scheme` 或
     * 手动设置）。切换是全局生效（写在 `document.documentElement` 上），
     * 与 Semi 暗色模式的全局语义一致——Semi 的 ConfigProvider 本身其实不
     * 承载主题能力（调研 `~/i/semi-design` 源码确认其 Context 只有
     * locale/direction/timeZone 等字段，没有 theme 相关 prop，暗色模式是
     * 脱离 ConfigProvider 的全局 DOM 属性操作），这里补的是 lotus 自己
     * `specs/phases/phase-5-global-media-tools.spec.md` 承诺、此前从未
     * 实现的能力，架构上选择让 ConfigProvider 承接这个副作用只是因为
     * "全局配置容器"这个定位与它已有的 locale 职责一致，非照搬 Semi。 */
    mode?: ConfigProviderThemeMode;
    /** 文字方向。未传时跟随 `locale.dir`（每个语言包自带默认方向，比如
     * 阿拉伯语 locale 会是 `dir: 'rtl'`），显式传入时覆盖 locale 自带的
     * 方向。写入原生 `dir` 属性到 `document.documentElement`（对齐 `mode`
     * 已有的"全局写在 documentElement 上"模式，不像 Semi 那样包一层
     * `<div class="semi-rtl">` 局部子树——调研 Semi 源码确认其 RTL 实现
     * 完全不依赖 CSS 逻辑属性，而是给每个组件写一份独立的 `rtl.scss`，
     * 用 `.semi-rtl .semi-xxx` 选择器对物理属性做显式镜像；lotus 对齐这
     * 个物理属性镜像的思路，但选择器用原生 `:root[dir="rtl"] .lotus-xxx`
     * 而非自定义 class，浏览器原生支持 `dir` 属性继承，语义更标准）。 */
    direction?: 'ltr' | 'rtl';
    /** 全局默认的浮层挂载容器，供 Popover/Tooltip 等浮层类组件在自身未显式传
     * getPopupContainer 时兜底使用（对齐 Semi ConfigProvider 语义：本身不做任何
     * DOM 操作，只是把函数原样透传给 Context，实际挂载逻辑在各浮层组件内部）。 */
    getPopupContainer?: () => HTMLElement | null;
    /** 全局默认时区（IANA 名如 `Asia/Shanghai`、`GMT±HH:00` 写法或数值小时偏移），
     * 供 DatePicker/TimePicker 在自身未显式传 timeZone 时兜底使用。 */
    timeZone?: string | number;
    /** 自定义响应式断点媒体查询，未传时使用内置默认值（对齐 Semi `defaultResponsiveMap`）。 */
    responsiveMap?: ResponsiveMap;
    /** 是否启用断点监听；默认 false（不注册任何 matchMedia 监听），首次调用
     * onBreakpoint 订阅时才按需注册，避免无人使用时的常驻监听开销。 */
    responsiveObserve?: boolean;
    children?: any;
}

export function ConfigProvider(
    &{
        locale = zhCN,
        mode,
        direction,
        getPopupContainer,
        timeZone,
        responsiveMap,
        responsiveObserve = false,
        children,
    }: ConfigProviderProps,
) @{
    // LocaleContext 下发的 dir 字段永远是"最终生效方向"（direction prop 优先于
    // locale 自带的默认方向），组件只需要读 `LocaleContext.get().value.dir`
    // 就能拿到权威当前方向，不需要关心 direction prop 是否单独覆盖过、也不需要
    // 再引入一个独立的 DirectionContext。
    let &[, localeTracked] = track<LocaleShape>(() => ({ ...locale, dir: direction ?? locale.dir }));
    LocaleContext.set(localeTracked);

    effect(() => {
        if (typeof document === 'undefined') return;
        if (mode === undefined) return;
        document.documentElement.setAttribute('data-theme', mode);
        return () => document.documentElement.removeAttribute('data-theme');
    });

    effect(() => {
        if (typeof document === 'undefined') return;
        const resolvedDirection = direction ?? locale.dir;
        document.documentElement.setAttribute('dir', resolvedDirection);
        return () => document.documentElement.removeAttribute('dir');
    });

    // onBreakpoint 订阅管理：与 Semi 一致的“懒注册”——responsiveObserve 关闭时
    // 完全不碰 matchMedia；开启后首个订阅者到来才真正注册监听，最后一个订阅者
    // 退订后立即注销，避免常驻开销。非响应式的普通闭包变量即可，因为这套状态
    // 只在 onBreakpoint() 调用时被读写，不参与模板渲染、不需要触发重渲染。
    let effectiveResponsiveMap = responsiveMap ?? DEFAULT_RESPONSIVE_MAP;
    let screensListeners = new Set<(screens: BreakpointScreens) => void>();
    let changeListeners = new Set<{ breakpoints?: ResponsiveBreakpoint[]; callback: (screen: ResponsiveBreakpoint, matches: boolean) => void }>();
    let unwatchBreakpoints: (() => void) | null = null;
    let currentScreens: BreakpointScreens = createEmptyBreakpointScreens();

    function notifyListeners(changedScreen?: ResponsiveBreakpoint, matches?: boolean) {
        screensListeners.forEach((listener) => listener(currentScreens));
        if (changedScreen !== undefined && matches !== undefined) {
            changeListeners.forEach(({ breakpoints, callback }) => {
                if (!breakpoints || breakpoints.includes(changedScreen)) callback(changedScreen, matches);
            });
        }
    }

    function ensureRegistered() {
        if (!responsiveObserve || unwatchBreakpoints) return;
        currentScreens = readBreakpointScreens(effectiveResponsiveMap);
        unwatchBreakpoints = watchAllBreakpoints(effectiveResponsiveMap, (screen, matches) => {
            if (currentScreens[screen] === matches) return;
            currentScreens = { ...currentScreens, [screen]: matches };
            notifyListeners(screen, matches);
        });
    }

    function maybeUnregister() {
        if (screensListeners.size === 0 && changeListeners.size === 0 && unwatchBreakpoints) {
            unwatchBreakpoints();
            unwatchBreakpoints = null;
            currentScreens = createEmptyBreakpointScreens();
        }
    }

    function onBreakpoint(arg1: any, arg2?: any): () => void {
        if (typeof arg1 === 'function') {
            const callback = arg1 as (screens: BreakpointScreens) => void;
            screensListeners.add(callback);
            ensureRegistered();
            callback(currentScreens);
            return () => {
                screensListeners.delete(callback);
                maybeUnregister();
            };
        }
        const breakpoints = Array.isArray(arg1) ? (arg1 as ResponsiveBreakpoint[]) : undefined;
        const callback = arg2 as (screen: ResponsiveBreakpoint, matches: boolean) => void;
        const entry = { breakpoints, callback };
        changeListeners.add(entry);
        ensureRegistered();
        (breakpoints ?? []).forEach((bp) => callback(bp, currentScreens[bp]));
        return () => {
            changeListeners.delete(entry);
            maybeUnregister();
        };
    }

    let &[, configTracked] = track<ConfigContextValue>(() => ({
        getPopupContainer,
        timeZone,
        responsiveMap: effectiveResponsiveMap,
        responsiveObserve,
        screens: currentScreens,
        onBreakpoint,
    }));
    ConfigContext.set(configTracked);

    effect(() => () => {
        unwatchBreakpoints?.();
        screensListeners.clear();
        changeListeners.clear();
    });

    <>{children}</>
}
