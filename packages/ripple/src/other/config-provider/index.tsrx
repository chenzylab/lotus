import { track, effect } from 'ripple';
import { zhCN, type LocaleShape } from '@lotus/locale';
import { LocaleContext } from './locale-context.js';

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
    children?: any;
}

export function ConfigProvider(&{ locale = zhCN, mode, direction, children }: ConfigProviderProps) @{
    let &[, localeTracked] = track<LocaleShape>(() => locale);
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

    <>{children}</>
}
