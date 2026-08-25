import { track, effect, untrack } from 'ripple';
import {
    AiChatDialogueFoundation,
    nextAiMessageId,
    type AiChatDialogueState,
    type AiChatMessage,
    type AiContentItem,
} from '@lotus/foundation/show/ai-chat-dialogue';
import { DialogueBox, type DialogueRoleConfig } from './dialogue-box.tsrx';

export type { DialogueRoleConfig };
export * from '@lotus/foundation/show/ai-chat-dialogue';

export interface AiChatDialogueApi {
    selectAll: () => void;
    deselectAll: () => void;
    scrollToBottom: () => void;
    scrollToTop: () => void;
}

export interface AiChatDialogueProps {
    /** 消息数组，传入即受控（对齐 Semi 完全受控模式）。 */
    chats?: AiChatMessage[];
    defaultChats?: AiChatMessage[];
    roleConfig?: DialogueRoleConfig;
    align?: 'leftRight' | 'leftAlign';
    mode?: 'bubble' | 'noBubble' | 'userBubble';
    hints?: string[];
    selecting?: boolean;
    showReset?: boolean;
    showReference?: boolean;
    disabledFileItemClick?: boolean;
    messageEditRender?: (message: AiChatMessage) => any;
    renderHintBox?: (args: { content: string; index: number; onHintClick: () => void }) => any;
    onChatsChange?: (chats: AiChatMessage[]) => void;
    onHintClick?: (hint: string) => void;
    onSelect?: (selectedIds: string[]) => void;
    onMessageCopy?: (message: AiChatMessage) => void;
    onMessageDelete?: (message: AiChatMessage) => void;
    onMessageReset?: (message: AiChatMessage) => void;
    onMessageEdit?: (message: AiChatMessage, content: string) => void;
    onMessageGoodFeedback?: (message: AiChatMessage) => void;
    onMessageBadFeedback?: (message: AiChatMessage) => void;
    onReferenceClick?: (message: AiChatMessage) => void;
    onAnnotationClick?: (item: AiContentItem) => void;
    onFileClick?: (item: AiContentItem) => void;
    onImageClick?: (item: AiContentItem) => void;
    getAiChatDialogueApi?: (api: AiChatDialogueApi) => void;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

/**
 * AiChatDialogue：AI 对话消息流展示（不含输入框——Semi 把输入框拆成独立的
 * AIChatInput 组件，两者配对但互相独立，本组件只负责渲染 `chats`）。
 * Foundation 是与 lotus 已有 Chat 组件不共享基类的独立轻量状态机（数据模型
 * 分叉太大：ContentItem[] 多块 vs 纯文本），streaming/reasoning 归约完全
 * 下沉到组件生命周期之外的纯函数（adapter-streaming.ts），供 SSE 事件处理器
 * 直接调用。命令式 API（selectAll/deselectAll/scrollToBottom/scrollToTop）
 * 通过 getAiChatDialogueApi 回调交出（对齐 Cropper 的 getCropperApi 既有模式，
 * Ripple 没有 ref 转发到自定义实例的机制）。
 */
export function AiChatDialogue(&{
    chats: chatsProp,
    defaultChats = [],
    roleConfig,
    align = 'leftRight',
    mode = 'bubble',
    hints = [],
    selecting: selectingProp,
    showReset = true,
    showReference = false,
    disabledFileItemClick = false,
    messageEditRender,
    renderHintBox,
    onChatsChange,
    onHintClick,
    onSelect,
    onMessageCopy,
    onMessageDelete,
    onMessageReset,
    onMessageEdit,
    onMessageGoodFeedback,
    onMessageBadFeedback,
    onReferenceClick,
    onAnnotationClick,
    onFileClick,
    onImageClick,
    getAiChatDialogueApi,
    style,
    class: className,
    'aria-label': ariaLabel,
}: AiChatDialogueProps) @{
    const isControlled = chatsProp !== undefined;

    let &[state] = track<AiChatDialogueState>(() => ({
        chats: chatsProp ?? defaultChats,
        selecting: selectingProp ?? false,
        selectedIds: new Set<string>(),
    }));

    const foundation = new AiChatDialogueFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<AiChatDialogueState>) => { state = { ...untrack(() => state), ...patch }; },
    });

    effect(() => {
        if (!isControlled) return;
        const next = chatsProp ?? [];
        if (next === untrack(() => state).chats) return;
        foundation.syncChats(next);
    });

    effect(() => {
        if (selectingProp === undefined) return;
        foundation.setSelecting(selectingProp);
    });

    let listEl: HTMLElement | null = null;
    let &[showBackToBottom] = track<boolean>(false);

    effect(() => {
        const count = state.chats.length;
        const el = untrack(() => listEl);
        if (!el) return;
        if (!untrack(() => showBackToBottom)) el.scrollTop = el.scrollHeight;
    });

    function scrollToBottom() {
        listEl?.scrollTo({ top: listEl.scrollHeight, behavior: 'smooth' });
    }

    function scrollToTop() {
        listEl?.scrollTo({ top: 0, behavior: 'smooth' });
    }

    function handleScroll() {
        const el = listEl;
        if (!el) return;
        const distanceToBottom = el.scrollHeight - el.scrollTop - el.clientHeight;
        showBackToBottom = distanceToBottom > 80;
    }

    getAiChatDialogueApi?.({
        selectAll: () => { onSelect?.([...foundation.selectAll()]); },
        deselectAll: () => { onSelect?.([...foundation.deselectAll()]); },
        scrollToBottom,
        scrollToTop,
    });

    function handleSelectToggle(id: string) {
        const next = foundation.toggleSelected(id);
        onSelect?.([...next]);
    }

    function handleCopy(message: AiChatMessage) {
        onMessageCopy?.(message);
    }

    function handleDelete(message: AiChatMessage) {
        const next = foundation.handleDelete(message.id, isControlled);
        onChatsChange?.(next);
        onMessageDelete?.(message);
    }

    function handleReset(message: AiChatMessage) {
        const next = foundation.handleReset(message.id, isControlled);
        onChatsChange?.(next);
        onMessageReset?.(message);
    }

    function handleLike(message: AiChatMessage) {
        const next = foundation.handleLike(message.id, isControlled);
        onChatsChange?.(next);
        if (next.find((m) => m.id === message.id)?.like) onMessageGoodFeedback?.(message);
    }

    function handleDislike(message: AiChatMessage) {
        const next = foundation.handleDislike(message.id, isControlled);
        onChatsChange?.(next);
        if (next.find((m) => m.id === message.id)?.dislike) onMessageBadFeedback?.(message);
    }

    function handleEditToggle(message: AiChatMessage) {
        const next = foundation.handleToggleEditing(message.id, isControlled);
        onChatsChange?.(next);
    }

    function handleEditSave(message: AiChatMessage, content: string) {
        const next = foundation.handleCommitEdit(message.id, content, isControlled);
        onChatsChange?.(next);
        onMessageEdit?.(message, content);
    }

    function handleHintClick(hint: string) {
        const next = foundation.handleHintClick(
            hint,
            (content) => ({ id: nextAiMessageId(), role: 'user', content, status: 'completed' }),
            isControlled,
        );
        onChatsChange?.(next);
        onHintClick?.(hint);
    }

    <>
        <div class={['lotus-ai-chat-dialogue', className ?? ''].filter(Boolean).join(' ')} style={style}>
            <ul
                class="lotus-ai-chat-dialogue-list"
                role="log"
                aria-live="polite"
                aria-label={ariaLabel ?? 'AI 对话消息列表'}
                ref={(node: HTMLElement | null) => { listEl = node; }}
                onScroll={handleScroll}
            >
                @for (const message of state.chats; key message.id) {
                    <DialogueBox
                        message={message}
                        roleConfig={roleConfig}
                        align={align}
                        mode={mode}
                        selecting={state.selecting}
                        selected={state.selectedIds.has(message.id)}
                        showReset={showReset}
                        showReference={showReference}
                        messageEditRender={messageEditRender}
                        onSelectToggle={handleSelectToggle}
                        onCopy={handleCopy}
                        onDelete={handleDelete}
                        onReset={handleReset}
                        onLike={handleLike}
                        onDislike={handleDislike}
                        onEditToggle={handleEditToggle}
                        onEditSave={handleEditSave}
                        onReference={(m) => onReferenceClick?.(m)}
                        onFileClick={onFileClick}
                        onImageClick={onImageClick}
                        onAnnotationClick={onAnnotationClick}
                        disabledFileItemClick={disabledFileItemClick}
                    />
                }
            </ul>

            @if (showBackToBottom) {
                <button type="button" class="lotus-ai-chat-dialogue-back-bottom" aria-label="回到底部" onClick={scrollToBottom}>↓</button>
            }

            @if (hints.length > 0) {
                <div class="lotus-ai-chat-dialogue-hints" role="group" aria-label="建议提示">
                    @for (const hint of hints; index i) {
                        @if (renderHintBox) {
                            <>{renderHintBox({ content: hint, index: i, onHintClick: () => handleHintClick(hint) })}</>
                        } @else {
                            <button type="button" class="lotus-ai-chat-dialogue-hint" onClick={() => handleHintClick(hint)}>
                                {hint}
                            </button>
                        }
                    }
                </div>
            }
        </div>

        <style>
            .lotus-ai-chat-dialogue {
                position: relative;
                display: flex;
                flex-direction: column;
                height: 100%;
                min-height: 0;
            }

            .lotus-ai-chat-dialogue-list {
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

            .lotus-ai-chat-dialogue-back-bottom {
                position: absolute;
                right: 16px;
                bottom: 64px;
                width: 32px;
                height: 32px;
                border-radius: 50%;
                border: 1px solid var(--lotus-color-border);
                background: var(--lotus-color-bg-1);
                color: var(--lotus-color-text-1);
                box-shadow: var(--lotus-shadow-elevated);
                cursor: pointer;
            }

            .lotus-ai-chat-dialogue-hints {
                display: flex;
                flex-wrap: wrap;
                gap: 8px;
                padding: 0 12px 12px;
            }

            .lotus-ai-chat-dialogue-hint {
                border: 1px solid var(--lotus-color-border);
                background: var(--lotus-color-bg-0);
                color: var(--lotus-color-text-1);
                border-radius: var(--lotus-border-radius-full);
                padding: 4px 12px;
                font-size: 13px;
                cursor: pointer;
            }

            .lotus-ai-chat-dialogue-hint:hover {
                border-color: var(--lotus-color-primary);
                color: var(--lotus-color-primary);
            }
        </style>
    </>
}
