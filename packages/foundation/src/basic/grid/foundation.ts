import { Foundation, type Adapter } from '../../base/adapter.js';
import { watchMediaQuery, BREAKPOINTS, type BreakpointKey } from '../../base/responsive.js';

export type Breakpoint = BreakpointKey;

export interface RowState {
  /** 当前视口命中的响应式断点集合，如视口 900px 时命中 { xs: true, sm: true, md: true }（向下兼容）。 */
  screens: Partial<Record<Breakpoint, boolean>>;
}

const BREAKPOINT_KEYS: (keyof typeof BREAKPOINTS)[] = ['sm', 'md', 'lg', 'xl', 'xxl'];

/**
 * Row 的响应式断点检测状态机：订阅每个断点的 matchMedia，聚合成 screens 状态供 Col 消费
 * （Col 根据 screens 决定用哪个尺寸档位的 span/offset）。参照 Semi Row 的 responsiveMap
 * 设计思路重新实现，不搬运代码。
 */
export class RowFoundation extends Foundation<RowState> {
  private unsubscribers: Array<() => void> = [];

  constructor(adapter: Adapter<RowState>) {
    super(adapter);
  }

  /** Adapter 在组件挂载时调用，开始监听所有断点；返回值供 Adapter 在卸载时调用以清理。 */
  init(): () => void {
    for (const key of BREAKPOINT_KEYS) {
      const query = `(min-width: ${BREAKPOINTS[key]}px)`;
      const unsubscribe = watchMediaQuery(query, {
        match: () => this.setScreen(key, true),
        unmatch: () => this.setScreen(key, false),
      });
      this.unsubscribers.push(unsubscribe);
    }
    // xs 恒为 true：视口宽度总是 >= 0，语义上"最小断点总是命中"
    this.setScreen('xs', true);

    return () => this.destroy();
  }

  destroy(): void {
    this.unsubscribers.forEach((unsub) => unsub());
    this.unsubscribers = [];
  }

  private setScreen(key: Breakpoint, matched: boolean): void {
    const { screens } = this.getState();
    this.setState({ screens: { ...screens, [key]: matched } });
  }

  /**
   * 计算某个响应式尺寸配置在当前 screens 下应生效的值：从最大断点向下找第一个当前视口命中
   * 且配置里存在该档位的值（对齐 CSS min-width 级联的"大屏幕设置也对小屏幕生效直到被覆盖"语义）。
   */
  static resolveResponsiveValue<T>(
    screens: Partial<Record<Breakpoint, boolean>>,
    config: Partial<Record<Breakpoint, T>>,
  ): T | undefined {
    const order: Breakpoint[] = ['xxl', 'xl', 'lg', 'md', 'sm', 'xs'];
    for (const key of order) {
      if (screens[key] && config[key] !== undefined) {
        return config[key];
      }
    }
    return undefined;
  }
}
