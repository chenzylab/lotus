import { track, effect, untrack } from 'ripple';
import {
    ChatFoundation,
    type ChatState,
    type ChatMessage,
    type SendHotKey,
} from '@lotus/foundation/show/chat';
import { TextArea } from '../../input/text-area/index.tsrx';
import { ChatMessageItem, type ChatRoleConfig } from './chat-message-item.tsrx';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export type { ChatMessage, ChatRoleConfig, SendHotKey };

export interface ChatProps {
    /** 消息数组，传入即受控（对齐 Semi 完全受控模式）。 */
    chats?: ChatMessage[];
    defaultChats?: ChatMessage[];
    roleConfig?: ChatRoleConfig;
    align?: 'leftRight' | 'leftAlign';
    mode?: 'bubble' | 'noBubble' | 'userBubble';
    placeholder?: string;
    sendHotKey?: SendHotKey;
    hints?: string[];
    canSend?: boolean;
    onChatsChange?: (chats: ChatMessage[]) => void;
    onMessageSend?: (content: string) => void;
    onMessageDelete?: (message: ChatMessage) => void;
    onMessageCopy?: (message: ChatMessage) => void;
    onMessageLike?: (message: ChatMessage) => void;
    onMessageDislike?: (message: ChatMessage) => void;
    onHintClick?: (hint: string) => void;
    onInputChange?: (value: string) => void;
    style?: Record<string, any>;
    class?: string;
}

export function Chat(&{
    chats: chatsProp,
    defaultChats = [],
    roleConfig,
    align = 'leftRight',
    mode = 'bubble',
    placeholder,
    sendHotKey = 'enter',
    hints = [],
    canSend = true,
    onChatsChange,
    onMessageSend,
    onMessageDelete,
    onMessageCopy,
    onMessageLike,
    onMessageDislike,
    onHintClick,
    onInputChange,
    style,
    class: className,
}: ChatProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    const isControlled = chatsProp !== undefined;

    let &[state] = track<ChatState>(() => ({
        chats: chatsProp ?? defaultChats,
        inputValue: '',
    }));

    const foundation = new ChatFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<ChatState>) => { state = { ...untrack(() => state), ...patch }; },
    });

    effect(() => {
        if (!isControlled) return;
        const next = chatsProp ?? [];
        if (next === untrack(() => state).chats) return;
        foundation.syncChats(next);
    });

    let listEl: HTMLElement | null = null;

    effect(() => {
        const count = state.chats.length;
        const el = untrack(() => listEl);
        if (!el) return;
        el.scrollTop = el.scrollHeight;
    });

    function handleSend() {
        const next = foundation.handleSend(canSend, isControlled);
        if (!next) return;
        onChatsChange?.(next);
        const sentMessage = next[next.length - 1];
        onMessageSend?.(sentMessage?.content ?? '');
    }

    function handleInputChange(value: string) {
        foundation.handleInputChange(value);
        onInputChange?.(value);
    }

    function handleEnterPress(event: KeyboardEvent) {
        if (!foundation.shouldSendOnEnterKey(sendHotKey, event.shiftKey)) return;
        event.preventDefault();
        handleSend();
    }

    function handleCopy(message: ChatMessage) {
        if (message.content) void navigator.clipboard?.writeText(message.content);
        onMessageCopy?.(message);
    }

    function handleDelete(message: ChatMessage) {
        const next = foundation.handleDelete(message.id, isControlled);
        onChatsChange?.(next);
        onMessageDelete?.(message);
    }

    function handleLike(message: ChatMessage) {
        const next = foundation.handleLike(message.id, isControlled);
        onChatsChange?.(next);
        onMessageLike?.(message);
    }

    function handleDislike(message: ChatMessage) {
        const next = foundation.handleDislike(message.id, isControlled);
        onChatsChange?.(next);
        onMessageDislike?.(message);
    }

    function handleHintClick(hint: string) {
        foundation.handleHintClick(hint);
        onHintClick?.(hint);
    }

    <>
        <div class={['lotus-chat', className ?? ''].filter(Boolean).join(' ')} style={style}>
            <ul class="lotus-chat-list" role="log" aria-label={locale.Chat.messageList} ref={(node: HTMLElement | null) => { listEl = node; }}>
                @for (const message of state.chats; key message.id) {
                    <ChatMessageItem
                        message={message}
                        align={align}
                        mode={mode}
                        roleConfig={roleConfig}
                        onCopy={handleCopy}
                        onLike={handleLike}
                        onDislike={handleDislike}
                        onDelete={handleDelete}
                    />
                }
            </ul>

            @if (hints.length > 0) {
                <div class="lotus-chat-hints" role="group" aria-label={locale.Chat.quickHints}>
                    @for (const hint of hints; key hint) {
                        <button type="button" class="lotus-chat-hint" onClick={() => handleHintClick(hint)}>
                            {hint}
                        </button>
                    }
                </div>
            }

            <div class="lotus-chat-input">
                <TextArea
                    value={state.inputValue}
                    placeholder={placeholder ?? locale.Chat.placeholder}
                    autosize={true}
                    onChange={handleInputChange}
                    onEnterPress={handleEnterPress}
                    aria-label={locale.Chat.inputLabel}
                />
                <button
                    type="button"
                    class="lotus-chat-send"
                    disabled={!canSend || !state.inputValue.trim()}
                    aria-label={locale.Chat.sendLabel}
                    onClick={handleSend}
                >
                    {locale.Chat.sendButton}
                </button>
            </div>
        </div>

        <style>
            .lotus-chat {
                display: flex;
                flex-direction: column;
                height: 100%;
                min-height: 0;
            }

            .lotus-chat-list {
                flex: 1;
                min-height: 0;
                overflow-y: auto;
                list-style: none;
                margin: 0;
                padding: 12px;
                display: flex;
                flex-direction: column;
                gap: 16px;
            }

            .lotus-chat :global(.lotus-chat-message) {
                display: flex;
                gap: 8px;
                align-items: flex-start;
            }

            .lotus-chat :global(.lotus-chat-message-right) {
                flex-direction: row-reverse;
            }

            .lotus-chat :global(.lotus-chat-message-body) {
                display: flex;
                flex-direction: column;
                gap: 4px;
                max-width: 70%;
            }

            .lotus-chat :global(.lotus-chat-message-right .lotus-chat-message-body) {
                align-items: flex-end;
            }

            .lotus-chat :global(.lotus-chat-message-name) {
                font-size: 12px;
                color: var(--lotus-color-text-2);
            }

            .lotus-chat :global(.lotus-chat-message-content) {
                word-break: break-word;
                white-space: pre-wrap;
            }

            .lotus-chat :global(.lotus-chat-message-bubble) {
                background: var(--lotus-color-fill-1);
                border-radius: var(--lotus-border-radius-medium);
                padding: 8px 12px;
            }

            .lotus-chat :global(.lotus-chat-message-right .lotus-chat-message-bubble) {
                background: var(--lotus-color-primary-light-default);
            }

            .lotus-chat :global(.lotus-chat-message-loading) {
                color: var(--lotus-color-text-2);
                letter-spacing: 2px;
            }

            .lotus-chat :global(.lotus-chat-message-actions) {
                display: flex;
                gap: 4px;
            }

            .lotus-chat :global(.lotus-chat-message-action) {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                width: 24px;
                height: 24px;
                border: none;
                background: transparent;
                color: var(--lotus-color-text-2);
                cursor: pointer;
                border-radius: var(--lotus-border-radius-small);
            }

            .lotus-chat :global(.lotus-chat-message-action:hover) {
                background: var(--lotus-color-fill-1);
                color: var(--lotus-color-text-0);
            }

            .lotus-chat :global(.lotus-chat-message-action-active) {
                color: var(--lotus-color-primary);
            }

            .lotus-chat :global(.lotus-chat-divider) {
                height: 1px;
                background: var(--lotus-color-border);
                margin: 0 12px;
                list-style: none;
            }

            .lotus-chat-hints {
                display: flex;
                flex-wrap: wrap;
                gap: 8px;
                padding: 0 12px 8px;
            }

            .lotus-chat-hint {
                border: 1px solid var(--lotus-color-border);
                background: var(--lotus-color-bg-0);
                color: var(--lotus-color-text-1);
                border-radius: var(--lotus-border-radius-full);
                padding: 4px 12px;
                font-size: 13px;
                cursor: pointer;
            }

            .lotus-chat-hint:hover {
                border-color: var(--lotus-color-primary);
                color: var(--lotus-color-primary);
            }

            .lotus-chat-input {
                display: flex;
                gap: 8px;
                align-items: flex-end;
                padding: 12px;
                border-top: 1px solid var(--lotus-color-border);
            }

            .lotus-chat-input :global(.lotus-textarea-wrapper) {
                flex: 1;
            }

            .lotus-chat-send {
                border: none;
                background: var(--lotus-color-primary);
                color: var(--lotus-color-white);
                border-radius: var(--lotus-border-radius-medium);
                padding: 8px 16px;
                cursor: pointer;
                flex-shrink: 0;
            }

            .lotus-chat-send:disabled {
                background: var(--lotus-color-fill-1);
                color: var(--lotus-color-text-3);
                cursor: not-allowed;
            }
        </style>
    </>
}
