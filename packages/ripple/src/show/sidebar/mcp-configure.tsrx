import { track, untrack, effect } from 'ripple';
import {
    MCPConfigureFoundation,
    type MCPConfigureState,
    type MCPMode,
    type MCPOption,
} from '@lotus/foundation/show/sidebar';
import { Input } from '../../input/input/index.tsrx';
import { RadioGroup } from '../../input/radio/group.tsrx';
import { Empty } from '../empty/index.tsrx';
import { Tooltip } from '../tooltip/index.tsrx';
import { Button } from '../../basic/button/index.tsrx';

export type { MCPOption, MCPMode };

export interface MCPConfigureProps {
    options?: MCPOption[];
    customOptions?: MCPOption[];
    filter?: (input: string, option: MCPOption) => boolean;
    placeholder?: string;
    onStatusChange?: (options: MCPOption[], customOptions: MCPOption[]) => void;
    onAddClick?: () => void;
    onConfigureClick?: (option: MCPOption) => void;
    onEditClick?: (option: MCPOption) => void;
    renderItem?: (args: { option: MCPOption; custom: boolean }) => any;
    class?: string;
    style?: Record<string, any>;
}

const MODE_OPTIONS = [
    { value: 'inner', label: '内置工具' },
    { value: 'custom', label: '自定义工具' },
];

/**
 * Sidebar.MCPConfigure：内置/自定义两组 MCP 工具的 Radio 二选一切换 + 300ms
 * 节流搜索（严格对齐 Semi 源码的 Radio 二选一交互，不采用 chenzy.design
 * 主动改进的并列双列表方案——UX 改版属于产品决策，本次不代为决定）。
 */
export function MCPConfigure(&{
    options,
    customOptions,
    filter,
    placeholder = '搜索 MCP 工具',
    onStatusChange,
    onAddClick,
    onConfigureClick,
    onEditClick,
    renderItem,
    class: className,
    style,
}: MCPConfigureProps) @{
    let &[state] = track<MCPConfigureState>({ mode: 'inner', inputValue: '', showOptions: options ?? [] });

    const foundation = new MCPConfigureFoundation(
        {
            getState: () => untrack(() => state),
            setState: (patch: Partial<MCPConfigureState>) => { state = { ...untrack(() => state), ...patch }; },
        },
        {
            getOptions: () => options ?? [],
            getCustomOptions: () => customOptions ?? [],
            filter,
        },
    );

    effect(() => {
        void options;
        void customOptions;
        untrack(() => foundation.refreshShowOptions());
    });

    function handleModeChange(mode: string | number) {
        foundation.handleModeChange(mode as MCPMode);
    }

    function handleSearch(value: string) {
        foundation.handleSearch(value);
    }

    function handleToggleActive(option: MCPOption) {
        const isCustom = untrack(() => state).mode === 'custom';
        const nextOptions = isCustom ? (options ?? []) : (options ?? []).map((o) => (o.value === option.value ? { ...o, active: !o.active } : o));
        const nextCustomOptions = isCustom ? (customOptions ?? []).map((o) => (o.value === option.value ? { ...o, active: !o.active } : o)) : (customOptions ?? []);
        onStatusChange?.(nextOptions, nextCustomOptions);
    }

    let &[isCustomMode] = track<boolean>(() => state.mode === 'custom');
    let &[showOptions] = track<MCPOption[]>(() => state.showOptions);

    <>
        <div class={['lotus-sidebar-mcp-configure', className ?? ''].filter(Boolean).join(' ')} style={style}>
            <RadioGroup options={MODE_OPTIONS} value={state.mode} onChange={handleModeChange} />

            <Input
                value={state.inputValue}
                placeholder={placeholder}
                showClear={true}
                onChange={handleSearch}
                style={{ marginTop: '8px', marginBottom: '8px' }}
            />

            @if (showOptions.length === 0) {
                <div class="lotus-sidebar-mcp-configure-empty">
                    <Empty title={isCustomMode ? '暂无自定义工具' : '暂无可用工具'} />
                    @if (isCustomMode) {
                        <Button theme="light" onClick={() => onAddClick?.()}>添加工具</Button>
                    }
                </div>
            } @else {
                <div class="lotus-sidebar-mcp-configure-list">
                    @for (const option of showOptions; key option.value) {
                        @if (renderItem) {
                            <>{renderItem({ option, custom: isCustomMode })}</>
                        } @else {
                            <div class={['lotus-sidebar-mcp-configure-item', option.disabled ? 'lotus-sidebar-mcp-configure-item-disabled' : ''].filter(Boolean).join(' ')}>
                                @if (option.icon) {
                                    <span class="lotus-sidebar-mcp-configure-icon">{option.icon}</span>
                                }
                                <div class="lotus-sidebar-mcp-configure-item-main">
                                    <div class="lotus-sidebar-mcp-configure-item-label">{option.label ?? option.value}</div>
                                    @if (option.desc) {
                                        <div class="lotus-sidebar-mcp-configure-item-desc">{option.desc}</div>
                                    }
                                </div>
                                @if (option.configure) {
                                    <button
                                        type="button"
                                        class="lotus-sidebar-mcp-configure-item-action"
                                        onClick={() => (isCustomMode ? onEditClick?.(option) : onConfigureClick?.(option))}
                                    >
                                        {isCustomMode ? '编辑' : '配置'}
                                    </button>
                                }
                                @if (option.disabled) {
                                    <Tooltip content="该工具已默认启用，不可关闭">
                                        <span
                                            role="switch"
                                            aria-checked={true}
                                            aria-disabled={true}
                                            class="lotus-sidebar-mcp-configure-switch lotus-sidebar-mcp-configure-switch-disabled"
                                        />
                                    </Tooltip>
                                } @else {
                                    <span
                                        role="switch"
                                        tabIndex={0}
                                        aria-checked={!!option.active}
                                        class={['lotus-sidebar-mcp-configure-switch', option.active ? 'lotus-sidebar-mcp-configure-switch-active' : ''].filter(Boolean).join(' ')}
                                        onClick={() => handleToggleActive(option)}
                                        onKeyDown={(e: KeyboardEvent) => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); handleToggleActive(option); } }}
                                    />
                                }
                            </div>
                        }
                    }
                </div>
            }
        </div>

        <style>
            .lotus-sidebar-mcp-configure {
                display: flex;
                flex-direction: column;
            }

            .lotus-sidebar-mcp-configure-empty {
                display: flex;
                flex-direction: column;
                align-items: center;
                gap: 12px;
                padding: 24px 0;
            }

            .lotus-sidebar-mcp-configure-list {
                display: flex;
                flex-direction: column;
                gap: 4px;
            }

            .lotus-sidebar-mcp-configure-item {
                display: flex;
                align-items: center;
                gap: 8px;
                padding: 8px;
                border-radius: var(--lotus-border-radius-small);
            }

            .lotus-sidebar-mcp-configure-item:hover {
                background: var(--lotus-color-fill-0);
            }

            .lotus-sidebar-mcp-configure-item-disabled {
                opacity: 0.6;
            }

            .lotus-sidebar-mcp-configure-icon {
                display: inline-flex;
                align-items: center;
                flex-shrink: 0;
            }

            .lotus-sidebar-mcp-configure-item-main {
                flex: 1;
                min-width: 0;
            }

            .lotus-sidebar-mcp-configure-item-label {
                font-size: 13px;
                color: var(--lotus-color-text-0);
            }

            .lotus-sidebar-mcp-configure-item-desc {
                font-size: 12px;
                color: var(--lotus-color-text-2);
            }

            .lotus-sidebar-mcp-configure-item-action {
                border: none;
                background: transparent;
                color: var(--lotus-color-primary);
                cursor: pointer;
                font-size: 12px;
                flex-shrink: 0;
            }

            .lotus-sidebar-mcp-configure-switch {
                display: inline-block;
                width: 28px;
                height: 16px;
                border-radius: 8px;
                background: var(--lotus-color-fill-2);
                position: relative;
                cursor: pointer;
                flex-shrink: 0;
                transition: background 0.15s;
            }

            .lotus-sidebar-mcp-configure-switch::after {
                content: '';
                position: absolute;
                top: 2px;
                left: 2px;
                width: 12px;
                height: 12px;
                border-radius: 50%;
                background: #fff;
                transition: transform 0.15s;
            }

            .lotus-sidebar-mcp-configure-switch-active {
                background: var(--lotus-color-primary);
            }

            .lotus-sidebar-mcp-configure-switch-active::after {
                transform: translateX(12px);
            }

            .lotus-sidebar-mcp-configure-switch-disabled {
                cursor: not-allowed;
            }
        </style>
    </>
}
