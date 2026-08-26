import { track } from 'ripple';
import { suggestionContent, type AiInputSuggestion } from '@lotus/foundation/show/ai-chat-input';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export interface SuggestionPanelProps {
    suggestions: AiInputSuggestion[];
    activeIndex: number;
    renderSuggestionItem?: (args: { suggestion: AiInputSuggestion; index: number; active: boolean }) => any;
    onSuggestClick: (suggestion: AiInputSuggestion) => void;
}

/** 建议提示面板内容：列表逐项渲染，activeIndex 高亮当前键盘导航位置。 */
export function SuggestionPanel(&{ suggestions, activeIndex, renderSuggestionItem, onSuggestClick }: SuggestionPanelProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    <>
        <div class="lotus-ai-input-suggestion-panel" role="listbox" aria-label={locale.AiChatInput.suggestionLabel}>
            @for (const suggestion of suggestions; index i) {
                @if (renderSuggestionItem) {
                    <>{renderSuggestionItem({ suggestion, index: i, active: i === activeIndex })}</>
                } @else {
                    <div
                        class={['lotus-ai-input-suggestion-item', i === activeIndex ? 'lotus-ai-input-suggestion-item-active' : ''].filter(Boolean).join(' ')}
                        role="option"
                        aria-selected={i === activeIndex}
                        onClick={() => onSuggestClick(suggestion)}
                    >
                        {suggestionContent(suggestion)}
                    </div>
                }
            }
        </div>

        <style>
            .lotus-ai-input-suggestion-panel {
                min-width: 200px;
                max-height: 240px;
                overflow-y: auto;
            }

            .lotus-ai-input-suggestion-item {
                padding: 6px 10px;
                border-radius: var(--lotus-border-radius-small);
                cursor: pointer;
                font-size: 13px;
                color: var(--lotus-color-text-0);
            }

            .lotus-ai-input-suggestion-item:hover,
            .lotus-ai-input-suggestion-item-active {
                background: var(--lotus-color-fill-0);
            }
        </style>
    </>
}
