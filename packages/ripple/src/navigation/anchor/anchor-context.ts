import { Context, type Tracked } from 'ripple';

/**
 * Anchor 根 Context：AnchorLink 声明式写法下，子组件 mount 时把自己的
 * href/title/disabled 注册进这里（对齐 Form.Field 的 registerField/
 * unregisterField 模式），unmount 时注销——Anchor 需要知道全部 href
 * 列表才能计算滚动高亮，这是与 RadioGroup/Radio（子组件只需读父状态，
 * 不需要向父注册自己）的关键差异。
 */
export interface AnchorRegisteredLink {
  href: string;
  title?: any;
  disabled?: boolean;
  level: number;
  parentHref: string | null;
}

export interface AnchorContextValue {
  activeLink: string | null;
  showTooltip: boolean | { position?: string };
  size: 'default' | 'small';
  registerLink: (link: AnchorRegisteredLink) => void;
  unregisterLink: (href: string) => void;
}

export const AnchorContext = new Context<Tracked<AnchorContextValue>>();

/**
 * AnchorLink 层级 Context：子孙 AnchorLink 读取父级 AnchorLink 的
 * level 并自动 +1，还原 Semi `<Link><Link /></Link>` 的 JSX 嵌套语义
 * （Ripple 无 children 遍历/克隆能力，层级不能像 Semi 那样在父组件里
 * 遍历 children 反推，只能靠子组件自己读祖先 Context 累加）。
 */
export const AnchorLevelContext = new Context<Tracked<{ level: number; parentHref: string | null }>>();
