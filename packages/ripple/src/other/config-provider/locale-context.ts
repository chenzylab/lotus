import { Context, type Tracked } from 'ripple';
import type { LocaleShape } from '@lotus/locale';

/**
 * 所有组件读取当前语言包的唯一入口。未被 <ConfigProvider> 包裹时
 * `LocaleContext.get()` 返回 undefined，组件侧统一 fallback 到 zh-CN
 * （对齐项目历史上所有硬编码文案都是中文这一事实，是成本最低的默认值——
 * 不需要每个组件各自决定 fallback 语言）。
 */
export const LocaleContext = new Context<Tracked<LocaleShape>>();
