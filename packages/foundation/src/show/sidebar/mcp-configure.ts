import { Foundation, type Adapter } from '../../base/adapter.js';
import { throttle } from '../../base/animate-value.js';

export interface MCPOption {
  value: string;
  label?: string;
  icon?: any;
  desc?: string;
  active?: boolean;
  disabled?: boolean;
  configure?: boolean;
}

export type MCPMode = 'inner' | 'custom';

export interface MCPConfigureState {
  mode: MCPMode;
  inputValue: string;
  /** 按 inputValue 过滤后、当前 mode 下要渲染的列表；搜索节流写回这里。 */
  showOptions: MCPOption[];
}

/** 默认过滤：大小写不敏感的 label/value 子串匹配（对齐 Semi 默认 filter 语义）。 */
export function filterMcpOptions(options: MCPOption[], input: string): MCPOption[] {
  if (!input) return options;
  const lower = input.toLowerCase();
  return options.filter((option) => (option.label ?? option.value).toLowerCase().includes(lower));
}

/** 切换单个选项的 active（不可变更新，返回新数组；disabled 项忽略切换）。 */
export function toggleMcpOptionActive(options: MCPOption[], value: string): MCPOption[] {
  return options.map((option) => {
    if (option.value !== value || option.disabled) return option;
    return { ...option, active: !option.active };
  });
}

export function countActiveMcpOptions(options: MCPOption[]): number {
  return options.reduce((count, option) => count + (option.active ? 1 : 0), 0);
}

export interface MCPConfigureAdapterExtra {
  getOptions: () => MCPOption[];
  getCustomOptions: () => MCPOption[];
  filter?: (input: string, option: MCPOption) => boolean;
}

/**
 * Sidebar.MCPConfigure 状态机：mode 路由（内置/自定义两组独立列表）+
 * 300ms 节流搜索过滤，对齐 Semi MCPConfigureContentFoundation 的量级。
 * `options`/`customOptions` 本身是 props（不进 state，与 lotus 既有
 * "Foundation 不持有 props、由 Adapter 按需取值"惯例一致），state 只落地
 * 派生出的 `showOptions`。
 */
export class MCPConfigureFoundation extends Foundation<MCPConfigureState> {
  private extra: MCPConfigureAdapterExtra;
  private throttledSearch: (input: string) => void;

  constructor(adapter: Adapter<MCPConfigureState>, extra: MCPConfigureAdapterExtra) {
    super(adapter);
    this.extra = extra;
    this.throttledSearch = throttle((input: string) => this.updateShowOptions(input), 300);
  }

  private currentModeOptions(): MCPOption[] {
    const { mode } = this.getState();
    return mode === 'inner' ? this.extra.getOptions() : this.extra.getCustomOptions();
  }

  private updateShowOptions(input: string): void {
    const options = this.currentModeOptions();
    const filter = this.extra.filter ?? ((value, option) => filterMcpOptions([option], value).length > 0);
    this.setState({ showOptions: options.filter((option) => filter(input, option)) });
  }

  /** 挂载/options 变化时立即（不节流）刷新一次展示列表。 */
  refreshShowOptions(): void {
    this.updateShowOptions(this.getState().inputValue);
  }

  handleSearch(input: string): void {
    this.setState({ inputValue: input });
    this.throttledSearch(input);
  }

  handleModeChange(mode: MCPMode): void {
    this.setState({ mode, inputValue: '' });
    this.updateShowOptions('');
  }
}
