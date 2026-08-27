/**
 * Chart 图表的纯函数模块：spec 组装 + 图表分类色板派生。
 *
 * 对齐调研结论——Semi 官方文档所称的"Semi DV"没有独立组件源码，业务代码
 * 直接使用 VChart（`@visactor/vchart`）原生 spec API，Semi 只贡献了一份
 * 通过闭源 DSM 平台生成、以 `@visactor/vchart-semi-theme` npm 包形式发布
 * 的主题 JSON。lotus 因此没有 Semi 组件实现可移植，只能移植"主题层"这一
 * 层——`@visactor/vchart-theme-utils` 导出的 `VChartExtendThemeHelper`
 * 抽象基类本身就是 Semi 那份主题包的底层实现，其 `tokenMap` 字段接受的
 * 是"VChart 内置语义槽位名 → CSS 变量名"的字符串映射（不是颜色值），
 * 运行时读取实际计算出的 CSS 变量值组装主题——这正好对齐 lotus 已有的
 * "CSS 变量驱动亮暗色切换"机制，不需要维护两份静态主题 JSON。
 *
 * 与 Lottie（lottie-web 极薄容器，无状态机）同一惯例：VChart 实例的生命
 * 周期（构造/updateSpec/release）完全交给第三方库自身管理，Foundation
 * 不维护状态机，只做"props → VChart 构造入参"这一步的纯函数转换。
 */

export type ChartType = 'bar' | 'line' | 'area' | 'pie' | 'funnel' | 'radar';

export interface ChartProps {
  /** 图表类型，决定落到 VChart spec 的 `type` 字段。 */
  type: ChartType;
  /** VChart 原生数据格式，透传给 spec.data（对齐 VChart `IDataValues[]`）。 */
  data: Array<{ id: string; values: Record<string, unknown>[] }>;
  /** 其余 VChart spec 字段（xField/yField/seriesField/title/legends 等）逐项透传，
   * 不做 lotus 自己的字段改名封装——VChart 的 spec 概念已经足够精简，重新包一层
   * 命名会制造两套需要对照记忆的 API，对使用方没有增益。 */
  spec?: Record<string, unknown>;
}

/**
 * 组装最终传给 `new VChart(spec, options)` 的 spec 对象：type/data 由 lotus 显式
 * 管理的 props 提供，其余字段整体透传自 `spec`，透传字段不覆盖 type/data
 * （对齐 Lottie `resolveLoadParams` 的"用户 params 兜底、关键字段显式优先"顺序，
 * 但这里反过来——type/data 是 lotus 强类型管理的必需字段，放在展开顺序最后
 * 确保不会被 spec 里同名字段意外覆盖）。
 */
export function resolveChartSpec(props: ChartProps): Record<string, unknown> {
  return {
    ...props.spec,
    type: props.type,
    data: props.data,
  };
}
