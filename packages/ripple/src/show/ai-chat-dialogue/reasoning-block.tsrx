import { track } from 'ripple';
import type { AiReasoningContentItem, AiMessageStatus } from '@lotus/foundation/show/ai-chat-dialogue';
import { Collapse } from '../collapse/index.tsrx';
import { CollapsePanel } from '../collapse/panel.tsrx';
import { MarkdownRender } from '../markdown-render/index.tsrx';
import { IconAiSearchLevel2, IconAiLoading } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export interface ReasoningBlockProps {
    item: AiReasoningContentItem;
    /** 消息整体状态：非 completed 时默认展开（AI 仍在"思考中"，过程可感知原则）。 */
    messageStatus?: AiMessageStatus;
}

/**
 * AI 推理（thinking）过程折叠块，直接复用已有 Collapse 承载展开/折叠语义
 * （对齐 Semi ReasoningWidget：默认展开条件是 `status !== 'completed'`）。
 */
export function ReasoningBlock(&{ item, messageStatus }: ReasoningBlockProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    let &[isThinking] = track<boolean>(() => messageStatus !== undefined && messageStatus !== 'completed');
    let &[text] = track<string>(() => (item.summary ?? item.content ?? []).join('\n\n'));

    <>
        <div class="lotus-ai-reasoning">
            <Collapse defaultActiveKey={isThinking ? 'reasoning' : undefined}>
                <CollapsePanel itemKey="reasoning" header={
                    <span class="lotus-ai-reasoning-header">
                        {isThinking ? <IconAiLoading /> : <IconAiSearchLevel2 />}
                        <span>{isThinking ? locale.AiChatDialogue.thinking : locale.AiChatDialogue.thoughtCompleted}</span>
                    </span>
                }>
                    <div class="lotus-ai-reasoning-content">
                        <MarkdownRender raw={text} />
                    </div>
                </CollapsePanel>
            </Collapse>
        </div>

        <style>
            .lotus-ai-reasoning {
                margin-bottom: 8px;
            }

            .lotus-ai-reasoning-header {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                color: var(--lotus-color-text-2);
                font-size: 13px;
            }

            .lotus-ai-reasoning-content {
                color: var(--lotus-color-text-2);
                font-size: 13px;
                padding-inline-start: 4px;
                border-inline-start: 2px solid var(--lotus-color-border);
            }
        </style>
    </>
}
