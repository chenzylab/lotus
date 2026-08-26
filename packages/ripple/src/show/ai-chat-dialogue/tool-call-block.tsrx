import { track } from 'ripple';
import { formatToolArguments, normalizeToolCallStatus, type AiToolCallContentItem, type AiMCPContentItem } from '@lotus/foundation/show/ai-chat-dialogue';
import { Collapse } from '../collapse/index.tsrx';
import { CollapsePanel } from '../collapse/panel.tsrx';
import { CodeHighlight } from '../code-highlight/index.tsrx';
import { IconTickCircle, IconAlertCircle, IconSpin } from '@lotus/icons';
import { zhCN, type LocaleShape } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export interface ToolCallBlockProps {
    item: AiToolCallContentItem | AiMCPContentItem;
}

function buildStatusLabel(locale: LocaleShape): Record<string, string> {
    return {
        in_progress: locale.AiToolCall.inProgress,
        completed: locale.AiToolCall.completed,
        failed: locale.AiToolCall.failed,
    };
}

/**
 * 工具调用（function_call）/ MCP 调用交互块：状态图标 + 折叠展示 JSON 格式化后的
 * 入参/出参，复用已有 CodeHighlight 做 JSON 语法高亮（对齐 chenzy.design
 * 已验证的"超越 Semi 基础展示"方案——Semi 自身只做纯文本裸展示）。
 */
export function ToolCallBlock(&{ item }: ToolCallBlockProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);
    let &[statusLabel] = track(() => buildStatusLabel(locale));

    let &[status] = track<string>(() => normalizeToolCallStatus(item.status));
    let &[formattedArgs] = track<string>(() => formatToolArguments(item.arguments));
    let &[formattedOutput] = track<string | undefined>(() => (item.output ? formatToolArguments(item.output) : undefined));
    let &[isMCP] = track<boolean>(() => item.type === 'mcp_call');

    <>
        <div class="lotus-ai-tool-call">
            <Collapse>
                <CollapsePanel itemKey="tool-call" header={
                    <span class="lotus-ai-tool-call-header">
                        {status === 'in_progress' ? <IconSpin /> : status === 'failed' ? <IconAlertCircle /> : <IconTickCircle />}
                        <span class="lotus-ai-tool-call-name">{item.name}</span>
                        {isMCP ? <span class="lotus-ai-tool-call-mcp-tag">{(item as AiMCPContentItem).server_label}</span> : null}
                        <span class={`lotus-ai-tool-call-status lotus-ai-tool-call-status-${status}`}>{statusLabel[status]}</span>
                    </span>
                }>
                    <div class="lotus-ai-tool-call-body">
                        <div class="lotus-ai-tool-call-section-title">{locale.AiToolCall.params}</div>
                        <CodeHighlight code={formattedArgs} language="json" lineNumber={false} />
                        @if (formattedOutput !== undefined) {
                            <>
                                <div class="lotus-ai-tool-call-section-title">{locale.AiToolCall.output}</div>
                                <CodeHighlight code={formattedOutput} language="json" lineNumber={false} />
                            </>
                        }
                        <div class="lotus-ai-tool-call-call-id">call_id: {item.call_id}</div>
                    </div>
                </CollapsePanel>
            </Collapse>
        </div>

        <style>
            .lotus-ai-tool-call {
                margin-bottom: 8px;
                border: 1px solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-small);
                padding: 0 8px;
            }

            .lotus-ai-tool-call-header {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                font-size: 13px;
            }

            .lotus-ai-tool-call-name {
                font-family: ui-monospace, 'SFMono-Regular', 'SF Mono', Menlo, Monaco, Consolas, monospace;
                color: var(--lotus-color-text-0);
            }

            .lotus-ai-tool-call-mcp-tag {
                font-size: 11px;
                padding: 0 4px;
                border-radius: var(--lotus-border-radius-small);
                background: var(--lotus-color-fill-1);
                color: var(--lotus-color-text-2);
            }

            .lotus-ai-tool-call-status {
                font-size: 12px;
                color: var(--lotus-color-text-2);
            }

            .lotus-ai-tool-call-status-failed {
                color: var(--lotus-color-danger);
            }

            .lotus-ai-tool-call-status-completed {
                color: var(--lotus-color-success);
            }

            .lotus-ai-tool-call-section-title {
                font-size: 12px;
                color: var(--lotus-color-text-2);
                margin: 6px 0 2px;
            }

            .lotus-ai-tool-call-call-id {
                margin-top: 6px;
                font-size: 11px;
                color: var(--lotus-color-text-3);
                font-family: ui-monospace, 'SFMono-Regular', 'SF Mono', Menlo, Monaco, Consolas, monospace;
            }
        </style>
    </>
}
