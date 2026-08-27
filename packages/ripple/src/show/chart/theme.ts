import { VChart, ThemeManager, type ITheme } from '@visactor/vchart';
import { VChartExtendThemeHelper } from '@visactor/vchart-theme-utils';
import type { PaletteTokenMap, DataSchemeTokenMap, ThemeMode } from '@visactor/vchart-theme-utils';

/**
 * lotus 品牌色 → VChart 主题的映射表，键名对齐 VChart 内置语义槽位
 * （`BuiltinColorPalette`），值是 lotus CSS 变量名（不带 `var()` 包裹——
 * 基类内部的 `getTokenValue()` 自行用 `getComputedStyle(...).getPropertyValue()`
 * 读取运行时计算值，CSS 自定义属性可继承，`document.body` 读到的值等同于
 * `:root` 上声明的值，不需要额外传 chartContainer）。
 *
 * 逐项对照 `@visactor/vchart-semi-theme` 的 `paletteTokenMap` 完成迁移：
 * lotus 命名规则与 Semi 几乎一一对应（`--lotus-color-text-0` 对
 * `--semi-color-text-0` 等），只有三个 slot 因为 lotus 没有独立的灰阶
 * scale / 纯白常量而改用语义最接近的既有 token 代替（均在下方逐条注明），
 * 不是遗漏，是刻意的等价映射。
 */
const paletteTokenMap: PaletteTokenMap = {
  backgroundColor: '--lotus-color-bg-0',
  borderColor: '--lotus-color-border',
  // Semi 用独立的 --semi-grey-5/3/2 三级灰阶表达"深/中/浅"描边语义；
  // lotus 没有单独的灰阶 token，但 text-1/text-2 本就是同一基色不同透明度
  // 的两级深浅，border 是同一基色里最浅的一级，语义上正好构成递减的三级。
  lineColor0: '--lotus-color-text-1',
  lineColor1: '--lotus-color-text-2',
  lineColor2: '--lotus-color-border',
  hoverBackgroundColor: '--lotus-color-fill-0',
  sliderRailColor: '--lotus-color-fill-0',
  // Semi 固定给纯白/近白值（控件手柄需要与任意背景保持视觉对比），
  // lotus 的 bg-0（亮色场景是纯白、暗色场景是深底）与之等价。
  sliderHandleColor: '--lotus-color-bg-0',
  sliderTrackColor: '--lotus-color-primary',
  popupBackgroundColor: { light: '--lotus-color-bg-0', dark: '--lotus-color-bg-3' },
  primaryFontColor: '--lotus-color-text-0',
  secondaryFontColor: '--lotus-color-text-1',
  tertiaryFontColor: '--lotus-color-text-2',
  axisLabelFontColor: '--lotus-color-text-2',
  disableFontColor: '--lotus-color-disabled-text',
  axisMarkerFontColor: '--lotus-color-bg-0',
  axisGridColor: '--lotus-color-border',
  axisDomainColor: '--lotus-color-text-2',
  crosshairBackgroundColor: '--lotus-color-fill-0',
  dataZoomHandleStrokeColor: { light: '--lotus-color-fill-2' },
  dataZoomChartColor: '--lotus-color-fill-1',
  playerControllerColor: '--lotus-color-primary',
  axisMarkerBackgroundColor: '--lotus-color-text-0',
  markLabelBackgroundColor: '--lotus-color-border',
  markLineStrokeColor: '--lotus-color-text-1',
  dangerColor: '--lotus-color-danger',
  warningColor: '--lotus-color-warning',
  successColor: '--lotus-color-success',
  infoColor: '--lotus-color-info',
};

/** 20 色图表分类色板，对应 `packages/tokens` 新增的 `--lotus-color-data-0..19`。 */
const dataSchemeTokenMap: DataSchemeTokenMap = [
  {
    scheme: Array.from({ length: 20 }, (_, i) => `--lotus-color-data-${i}`),
  },
];

/**
 * lotus 版的 VChart 主题 helper，继承 `@visactor/vchart-theme-utils` 导出的
 * 抽象基类——这正是 Semi 官方主题包（`@visactor/vchart-semi-theme`）的实现
 * 方式，不是 lotus 自创的接入点。
 *
 * 不复用基类的 `init()`/`getCurrentMode()`：两者硬编码读取
 * `document.body` 的 `data-theme` 属性（VisActor 官方约定的挂载点），
 * 而 lotus 的 `ConfigProvider.mode` 写在 `document.documentElement` 上
 * （对齐已有 `mode` 暗色主题"全局写在 documentElement 上"的既定模式），
 * 两者的属性宿主元素不一致，硬套基类逻辑会导致 mode 检测永远落回
 * 'light'——因此只借用 `generateTheme()` 这个不碰 DOM 属性检测、纯粹
 * 做"colorScheme token 值替换"的方法，mode 切换的触发时机改由 lotus
 * 自己在 `.tsrx` 渲染层用 `LocaleContext`/`effect` 驱动的地方显式调用
 * `applyLotusChartTheme()`。
 *
 * `baseTheme` 直接取 VChart 自带的内置 'light'/'dark' 主题（`ThemeManager`
 * 模块加载时已预注册 dark，light 是默认主题），而不是自己手写一份骨架——
 * `generateTheme()` 内部会访问 `baseTheme[mode].colorScheme.default.{palette,dataScheme}`
 * 取"未被 token 覆盖字段的兜底值"，用 VChart 官方默认主题当基底既保证结构
 * 合法，也让"lotus 没有覆盖到的 series/component 视觉细节"落回 VChart
 * 官方默认效果而不是 lotus 拍脑袋的占位值。
 */
class VChartLotusThemeHelper extends VChartExtendThemeHelper {
  themeModeAttribute = 'data-theme';
  themeNamePrefix = 'lotusChart';
  baseTheme: Record<ThemeMode, ITheme> = {
    light: ThemeManager.getTheme('light'),
    dark: ThemeManager.getTheme('dark'),
  };
  tokenMap = { palette: paletteTokenMap, dataScheme: dataSchemeTokenMap };
}

let themeHelper: VChartLotusThemeHelper | null = null;

function getThemeHelper(): VChartLotusThemeHelper {
  themeHelper ??= new VChartLotusThemeHelper({ isWatchingMode: false });
  return themeHelper;
}

function currentDocumentMode(): ThemeMode {
  return document.documentElement.getAttribute('data-theme') === 'dark' ? 'dark' : 'light';
}

/**
 * 生成/注册（若尚未注册）当前亮暗模式对应的 lotus VChart 主题，返回主题名，
 * 供 `<Chart>` 组件传入 `new VChart(spec, { theme: themeName })`。
 * 由调用方（`.tsrx` 渲染层）在 mode 变化时（`effect` 监听 `ConfigProvider.mode`
 * 或直接监听 `documentElement` 的 `data-theme` 属性）重新调用，Chart 组件
 * 自身不感知"什么时候该重新取主题"这件事，保持 Foundation/主题模块的
 * 纯函数性质。
 */
export function ensureLotusChartTheme(): string {
  const helper = getThemeHelper();
  const mode = currentDocumentMode();
  const themeName = helper.generateThemeName({ mode });
  if (!VChart.ThemeManager.themeExist(themeName)) {
    VChart.ThemeManager.registerTheme(themeName, helper.generateTheme({ mode }));
  }
  return themeName;
}
