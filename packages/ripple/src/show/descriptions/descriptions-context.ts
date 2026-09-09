import { Context, type Tracked } from 'ripple';
import type { DescriptionsAlign } from './index.tsrx';

/**
 * Descriptions 下发给 DescriptionsItem 的共享状态：children 声明式写法
 * （<Descriptions><DescriptionsItem itemKey="..." .../></Descriptions>）下，
 * Item 需要知道父组件的 align 才能决定渲染 plain 单栏还是 th/td 双栏结构
 * ——对齐 Semi DescriptionsContext（align/layout），但 lotus 只在
 * layout==='vertical' 时支持 children 声明式（horizontal 需要先收集全部
 * item 信息做 column 分组，这依赖 React.Children.toArray 等价机制，Ripple
 * 没有对应能力，是已知的架构限制，见 index.tsrx 顶部注释）。
 */
export interface DescriptionsContextValue {
  align: DescriptionsAlign;
}

export const DescriptionsContext = new Context<Tracked<DescriptionsContextValue>>();
