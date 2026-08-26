import { track } from 'ripple';
import { mcpConfigureLabel, type MCPOption } from '@lotus/foundation/show/ai-chat-input';
import { Dropdown } from '../dropdown/index.tsrx';
import { DropdownMenu } from '../dropdown/menu.tsrx';
import { DropdownItem } from '../dropdown/item.tsrx';
import { Button } from '../../basic/button/index.tsrx';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export interface ConfigureMcpProps {
    options: MCPOption[];
    showConfigure?: boolean;
    onConfigureButtonClick?: () => void;
    class?: string;
    style?: Record<string, any>;
}

/**
 * Configure.Mcp：footer 配置区的 MCP 计数下拉触发器（"MCP · N"），点击展开
 * 已启用工具列表，"配置"按钮触发 `onConfigureButtonClick`——对齐调研结论：
 * Semi 的 Configure.Mcp 只是一个计数展示 + 出口，真正的工具浏览/搜索/选择由
 * 消费方提供；lotus 用已完整实现的 `Sidebar.MCPConfigure` 承接这个出口，
 * 两者共享 `MCPOption` 类型，不重复定义。
 */
export function ConfigureMcp(&{ options, showConfigure = true, onConfigureButtonClick, class: className, style }: ConfigureMcpProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    <>
        <Dropdown
            class={['lotus-ai-input-configure-mcp', className ?? ''].filter(Boolean).join(' ')}
            style={style}
            trigger="click"
            render={
                <div class="lotus-ai-input-configure-mcp-panel">
                    <div class="lotus-ai-input-configure-mcp-header">
                        <span class="lotus-ai-input-configure-mcp-header-title">{mcpConfigureLabel(options)}</span>
                        @if (showConfigure) {
                            <Button theme="outline" size="small" onClick={() => onConfigureButtonClick?.()}>{locale.ConfigureMcp.configure}</Button>
                        }
                    </div>
                    <DropdownMenu>
                        @for (const option of options; key option.value) {
                            <DropdownItem>{option.label ?? option.value}</DropdownItem>
                        }
                    </DropdownMenu>
                </div>
            }
        >
            <button type="button" class="lotus-ai-input-configure-mcp-trigger">{mcpConfigureLabel(options)}</button>
        </Dropdown>

        <style>
            .lotus-ai-input-configure-mcp-trigger {
                border: 1px solid var(--lotus-color-border);
                background: var(--lotus-color-bg-0);
                color: var(--lotus-color-text-1);
                border-radius: var(--lotus-border-radius-full);
                padding: 2px 10px;
                font-size: 12px;
                cursor: pointer;
            }

            .lotus-ai-input-configure-mcp-panel {
                min-width: 200px;
            }

            .lotus-ai-input-configure-mcp-header {
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 4px 8px 8px;
                border-bottom: 1px solid var(--lotus-color-border);
                margin-bottom: 4px;
            }

            .lotus-ai-input-configure-mcp-header-title {
                font-size: 12px;
                color: var(--lotus-color-text-2);
            }
        </style>
    </>
}
