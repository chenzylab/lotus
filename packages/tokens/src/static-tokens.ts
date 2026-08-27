/**
 * L3/L2 静态变量（非色相算法生成类）。
 * 数值权威来源：`~/i/semi-design/packages/semi-theme-default/scss/{global.scss,variables.scss}`
 * （AGENTS.md 指定 DESIGN.md 为一手参照，该 scss 是 DESIGN.md 摘要的完整底层实现，
 * 优先级更高——凡与 DESIGN.md 冲突处以此文件为准，因为它是构建产物直接消费的源头）。
 * 亮/暗双模式均需要独立取值，不做简单取反。
 */

export interface ModeValue {
  light: string;
  dark: string;
}

/**
 * 背景/表面层级，共 5 层（Semi 源码 `--semi-color-bg-0` ~ `bg-4`）：
 * 0 = 最下层（页面底色），1 = 次下层（需要提升的内容），2 = 中间层（模态等容器），
 * 3 = 次上层（通知/Toast），4 = 最上层（特殊场景）。
 * 亮色模式下 0-4 视觉上均为白色（靠阴影/边框区分层级），暗色模式下逐级提亮。
 */
export const bg: Record<'bg0' | 'bg1' | 'bg2' | 'bg3' | 'bg4', ModeValue> = {
  bg0: { light: '#ffffff', dark: '#16161a' },
  bg1: { light: '#ffffff', dark: '#232429' },
  bg2: { light: '#ffffff', dark: '#35363c' },
  bg3: { light: '#ffffff', dark: '#43444a' },
  bg4: { light: '#ffffff', dark: '#4f5159' },
};

/** 组件填充层级：0 = 默认（如输入框底色），1 = hover，2 = active/pressed。 */
export const fill: Record<'fill0' | 'fill1' | 'fill2', ModeValue> = {
  fill0: { light: 'rgba(46, 50, 56, 0.05)', dark: 'rgba(255, 255, 255, 0.12)' },
  fill1: { light: 'rgba(46, 50, 56, 0.09)', dark: 'rgba(255, 255, 255, 0.16)' },
  fill2: { light: 'rgba(46, 50, 56, 0.13)', dark: 'rgba(255, 255, 255, 0.20)' },
};

/**
 * 文字/图标颜色层级，共 4 层：0 = 最主要，1 = 稍次要，2 = 次要，3 = 最次要（等同 disabled-text）。
 * 官网 https://semi.design/zh-CN/basic/tokens 明确措辞"四个不同层级"，Semi 源码 text-3 与
 * disabled-text 数值完全一致，故 text-3 不单独重复定义，disabled.text 即复用该值。
 */
export const text: Record<'text0' | 'text1' | 'text2' | 'text3', ModeValue> = {
  text0: { light: '#1c1f23', dark: '#f9f9f9' },
  text1: { light: 'rgba(28, 31, 35, 0.8)', dark: 'rgba(249, 249, 249, 0.8)' },
  text2: { light: 'rgba(28, 31, 35, 0.62)', dark: 'rgba(249, 249, 249, 0.6)' },
  text3: { light: 'rgba(28, 31, 35, 0.35)', dark: 'rgba(249, 249, 249, 0.35)' },
};

export const border: ModeValue = {
  light: 'rgba(28, 31, 35, 0.08)',
  dark: 'rgba(255, 255, 255, 0.08)',
};

/** 用于模拟描边的阴影颜色（如 Table 无边框场景的伪装描边效果）。 */
export const shadowBorder: ModeValue = {
  light: 'rgba(0, 0, 0, 0.04)',
  dark: 'rgba(0, 0, 0, 0.04)',
};

/** 蒙层背景色（Modal/Drawer 遮罩）。 */
export const overlayBg: ModeValue = {
  light: 'rgba(22, 22, 26, 0.6)',
  dark: 'rgba(22, 22, 26, 0.6)',
};

/** 焦点态边框：与 Primary 默认色一致，用于表单控件 focus 边框。 */
export const focusBorder: ModeValue = {
  light: '#0064fa',
  dark: '#54a9ff',
};

/** 禁用态：背景、文字（等同 text-3）、边框、填充四件套。 */
export const disabled: Record<'bg' | 'text' | 'border' | 'fill', ModeValue> = {
  bg: { light: '#e6e8ea', dark: '#2e3238' },
  text: text.text3,
  border: { light: '#e6e8ea', dark: '#2e3238' },
  fill: { light: 'rgba(46, 50, 56, 0.04)', dark: 'rgba(255, 255, 255, 0.04)' },
};

/** 链接色：默认/hover/active/visited 四态，与 Primary 色相一致。 */
export const link: Record<'default' | 'hover' | 'active' | 'visited', ModeValue> = {
  default: { light: '#0064fa', dark: '#54a9ff' },
  hover: { light: '#0059df', dark: '#7cbbff' },
  active: { light: '#004ec3', dark: '#2e82ff' },
  visited: { light: '#0064fa', dark: '#54a9ff' },
};

/** 高亮文本（如 Highlight 组件命中关键词）背景与文字色。 */
export const highlight: Record<'bg' | 'text', ModeValue> = {
  bg: { light: '#fdd453', dark: 'rgba(255, 228, 92, 1)' },
  text: { light: '#000000', dark: '#ffffff' },
};

/** 悬浮阴影：Modal/Popover/Toast/Dropdown 等浮层元素使用。 */
export const elevation: ModeValue = {
  light: '0 0 1px rgba(0, 0, 0, 0.3), 0 4px 14px rgba(0, 0, 0, 0.1)',
  dark: 'inset 0 0 0 1px rgba(255, 255, 255, 0.1), 0 4px 14px rgba(0, 0, 0, 0.25)',
};

/** 圆角层级：extraSmall/small 用于基础控件内部元素，medium 用于菜单类，large 用于大容器，circle/full 用于头像/徽标/胶囊。 */
export const radius = {
  extraSmall: '3px',
  small: '3px',
  medium: '6px',
  large: '12px',
  circle: '50%',
  full: '9999px',
};

/**
 * 完整间距刻度（9 级，对齐 Semi `$spacing-*` 变量）：从 none 到 super-loose。
 * 之前版本只有 5 级（xs/sm/md/lg/xl），现按权威源码补齐两端的极值档位。
 */
export const spacing = {
  none: '0px',
  superTight: '2px',
  extraTight: '4px',
  tight: '8px',
  baseTight: '12px',
  base: '16px',
  baseLoose: '20px',
  loose: '24px',
  extraLoose: '32px',
  superLoose: '40px',
};

/** 控件高度三档：常见于 Input/Button/Select 等表单类组件的 size prop。 */
export const controlHeight = {
  small: '24px',
  default: '32px',
  large: '40px',
};

/** 描边宽度：默认 0（大多数组件无描边），控件默认态 1px，控件 focus 态 1px（数值相同但语义独立，便于未来分别调整）。 */
export const borderWidth = {
  none: '0',
  control: '1px',
  controlFocus: '1px',
};

/** Z-index 分层，覆盖组件库常见的层级冲突场景。数值直接对齐 Semi 源码以保持与常见第三方库（如 antd modal 1000）的层级习惯兼容。 */
export const zIndex = {
  portal: 1,
  affix: 10,
  backTop: 10,
  badge: 10,
  resizableHandler: 10,
  tableFixed: 101,
  modal: 1000,
  modalMask: 1000,
  toast: 1010,
  notification: 1010,
  popover: 1030,
  dropdown: 1050,
  tooltip: 1060,
  imagePreview: 1070,
  dragItemMove: 2000,
};

/** 字体栈：Inter 优先，中文回退 PingFang SC / 微软雅黑，全平台无衬线兜底。 */
export const fontFamily =
  '"Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", "PingFang SC", "Hiragino Sans GB", "Microsoft YaHei", "Helvetica Neue", Helvetica, Arial, sans-serif';

/**
 * 字重五档，对齐 Semi `typography/variables.scss` 的 light/regular/medium/semibold/bold 刻度。
 * 标题（h1-h6）默认用 semibold（600），正文用 regular（400）。
 */
export const fontWeight = {
  light: '200',
  regular: '400',
  medium: '500',
  semibold: '600',
  bold: '700',
};

export interface TypeScale {
  fontSize: string;
  lineHeight: string;
  fontWeight: string;
}

/** 完整字体排印刻度：H1-H6（600 字重，即 semibold）+ Body（400/14px）+ Label（400/12px）。 */
export const typography: Record<'h1' | 'h2' | 'h3' | 'h4' | 'h5' | 'h6' | 'body' | 'label', TypeScale> = {
  h1: { fontSize: '32px', lineHeight: '44px', fontWeight: fontWeight.semibold },
  h2: { fontSize: '28px', lineHeight: '40px', fontWeight: fontWeight.semibold },
  h3: { fontSize: '24px', lineHeight: '32px', fontWeight: fontWeight.semibold },
  h4: { fontSize: '20px', lineHeight: '28px', fontWeight: fontWeight.semibold },
  h5: { fontSize: '18px', lineHeight: '24px', fontWeight: fontWeight.semibold },
  h6: { fontSize: '16px', lineHeight: '22px', fontWeight: fontWeight.semibold },
  body: { fontSize: '14px', lineHeight: '20px', fontWeight: fontWeight.regular },
  label: { fontSize: '12px', lineHeight: '16px', fontWeight: fontWeight.regular },
};

/** 图标默认尺寸刻度。 */
export const iconSize = {
  extraSmall: '8px',
  small: '12px',
  medium: '16px',
  large: '20px',
  extraLarge: '24px',
};

/**
 * 响应式断点（min-width，对齐业界通用的 6 档栅格断点惯例，Grid/Layout 等组件消费）。
 * xs 无最小宽度（覆盖 0 到 sm 之前），故不在此表内，由消费方用 max-width 单独处理。
 */
export const breakpoint = {
  sm: '576px',
  md: '768px',
  lg: '992px',
  xl: '1200px',
  xxl: '1600px',
};

/**
 * Tag 装饰色板：16 个纯装饰性色相（不含语义），供 Tag/Avatar 等需要"多彩但非语义"标签场景
 * 使用，与 7 语义色（primary/secondary/.../info）是完全独立的体系——语义色表达"这是什么类型
 * 的信息"，装饰色只用于视觉区分/分类标记，不承载语义。
 * 数值来源：`~/i/semi-design/packages/semi-theme-default/scss/_palette.scss` 的各色相
 * level-5（基准）值，亮/暗两组 RGB triplet 各自转换为 hex（未复用 Semi 代码，只取数值）。
 * 与语义色不同，装饰色只提供单一基准值（不生成完整 0-9 色阶、不带 hover/active/disabled
 * 状态集）——Tag 场景通常整色块填充或整色块浅底，不需要精细的交互态分级。
 */
export const tagDecorativeColor: Record<
  'amber' | 'blue' | 'cyan' | 'green' | 'grey' | 'indigo' | 'lightBlue' | 'lightGreen' | 'lime' | 'orange' | 'pink' | 'purple' | 'red' | 'teal' | 'violet' | 'yellow',
  ModeValue
> = {
  amber: { light: '#f0b114', dark: '#f5ca50' },
  blue: { light: '#0064fa', dark: '#54a9ff' },
  cyan: { light: '#05a4b6', dark: '#38bbc6' },
  green: { light: '#3bb346', dark: '#5dc264' },
  grey: { light: '#6b7075', dark: '#888d92' },
  indigo: { light: '#3f51b5', dark: '#5f71c5' },
  lightBlue: { light: '#0095ee', dark: '#40b4f3' },
  lightGreen: { light: '#7bb63c', dark: '#97c65f' },
  lime: { light: '#9bd100', dark: '#aedc3a' },
  orange: { light: '#fc8800', dark: '#ffae43' },
  pink: { light: '#e91e63', dark: '#ef5686' },
  purple: { light: '#9e28b3', dark: '#b553c2' },
  red: { light: '#f93920', dark: '#fc725a' },
  teal: { light: '#00b3a1', dark: '#33c2b0' },
  violet: { light: '#6a3ac7', dark: '#8865d4' },
  yellow: { light: '#fac800', dark: '#fdde43' },
};

/**
 * 图表分类色板（20 色，供 Chart 组件的多系列/多分类数据着色使用）。
 * 亮暗模式共用同一份取值——分类色板追求"系列间视觉可区分度"这一个客观属性，
 * 不像语义色/装饰色那样需要跟随背景明暗调整对比度（对齐 VChart 官方
 * `@visactor/vchart-semi-theme` 包的 `dark/color-scheme.js` 直接复用
 * `common/data-scheme.js` 同一份颜色数组的既定做法，取值来源也是该包）。
 */
export const chartDataColor: string[] = [
  '#5769ff', '#8ed4e7', '#f58700', '#dcb7fc', '#4a9cf7',
  '#f3cc35', '#fe8090', '#8bd7d2', '#83b023', '#e9a5e5',
  '#30a7ce', '#f9c064', '#b171f9', '#77b6f9', '#c88f02',
  '#ffaab2', '#33b0ab', '#b6d781', '#d458d4', '#bcc6ff',
];

/** AI 专属渐变色变量（Phase 1 起被 Button/Icon/Tag/FloatButton 的 AI 主题变体消费）。 */
export const aiColor = {
  general: 'linear-gradient(90deg, #5C4CFF 0%, #A64EFF 50%, #FF57C6 100%)',
  // hover/active 是 general 渐变整体调深的固定色值（对应 Semi 的 --semi-color-ai-general-hover/active），
  // 渐变字符串无法用 withAlpha() 派生透明度，故各色标直接给出调深后的十六进制值。
  generalHover: 'linear-gradient(90deg, #4B3ACC 0%, #8A3ECC 50%, #CC4599 100%)',
  generalActive: 'linear-gradient(90deg, #3A2D9E 0%, #6E30A3 50%, #A3357A 100%)',
  purpleLight: 'rgba(166, 71, 255, 1)',
  purpleDark: 'rgba(195, 117, 255, 1)',
  backgroundTopLight: 'rgba(166, 71, 255, 0.08)',
  backgroundTopDark: 'rgba(195, 117, 255, 0.16)',
  backgroundBottomLight: 'rgba(92, 76, 255, 0.04)',
  backgroundBottomDark: 'rgba(92, 76, 255, 0.12)',
};
