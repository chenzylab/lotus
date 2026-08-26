import { track } from 'ripple';
import { normalizeAiContent, extractPlainText, type AiChatMessage, type AiContentItem } from '@lotus/foundation/show/ai-chat-dialogue';
import { Avatar } from '../avatar/index.tsrx';
import { Checkbox } from '../../input/checkbox/index.tsrx';
import { ContentItemRenderer } from './content-item-renderer.tsrx';
import { MessageEditor } from './message-editor.tsrx';
import { IconCopy, IconLikeThumb, IconDislikeThumb, IconDelete, IconRefresh, IconEdit, IconShareStroked } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export interface DialogueRoleMeta {
    name?: string;
    avatar?: string;
}

export type DialogueRoleConfig = Partial<Record<string, DialogueRoleMeta>>;

export interface DialogueBoxProps {
    message: AiChatMessage;
    roleConfig?: DialogueRoleConfig;
    align: 'leftRight' | 'leftAlign';
    mode: 'bubble' | 'noBubble' | 'userBubble';
    selecting: boolean;
    selected: boolean;
    showReset: boolean;
    showReference: boolean;
    messageEditRender?: (message: AiChatMessage) => any;
    onSelectToggle: (id: string) => void;
    onCopy: (message: AiChatMessage) => void;
    onDelete: (message: AiChatMessage) => void;
    onReset: (message: AiChatMessage) => void;
    onLike: (message: AiChatMessage) => void;
    onDislike: (message: AiChatMessage) => void;
    onEditToggle: (message: AiChatMessage) => void;
    onEditSave: (message: AiChatMessage, content: string) => void;
    onReference: (message: AiChatMessage) => void;
    onFileClick?: (item: AiContentItem) => void;
    onImageClick?: (item: AiContentItem) => void;
    onAnnotationClick?: (item: AiContentItem) => void;
    disabledFileItemClick?: boolean;
}

function roleMeta(role: string, roleConfig?: DialogueRoleConfig): DialogueRoleMeta {
    return roleConfig?.[role] ?? {};
}

function showBubble(mode: DialogueBoxProps['mode'], role: string): boolean {
    if (mode === 'noBubble') return false;
    if (mode === 'userBubble') return role === 'user';
    return true;
}

/**
 * 单条消息渲染：头像/标题/多块内容（ContentItem[] 逐个渲染）/操作栏。
 * `editing=true` 时整体切换成 MessageEditor（或调用方通过 messageEditRender
 * 完全接管）。
 */
export function DialogueBox(&{
    message,
    roleConfig,
    align,
    mode,
    selecting,
    selected,
    showReset,
    showReference,
    messageEditRender,
    onSelectToggle,
    onCopy,
    onDelete,
    onReset,
    onLike,
    onDislike,
    onEditToggle,
    onEditSave,
    onReference,
    onFileClick,
    onImageClick,
    onAnnotationClick,
    disabledFileItemClick = false,
}: DialogueBoxProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    const meta = roleMeta(message.role, roleConfig);
    const isUser = message.role === 'user';
    const onRight = align === 'leftRight' && isUser;
    const bubble = showBubble(mode, message.role);
    let &[contentItems] = track<AiContentItem[]>(() => normalizeAiContent(message.content));

    function handleCopy() {
        void navigator.clipboard?.writeText(extractPlainText(message.content));
        onCopy(message);
    }

    <>
        <li
            class={['lotus-ai-dialogue-box', onRight ? 'lotus-ai-dialogue-box-right' : 'lotus-ai-dialogue-box-left'].filter(Boolean).join(' ')}
            data-role={message.role}
            data-message-id={message.id}
        >
            @if (selecting) {
                <Checkbox checked={selected} onChange={() => onSelectToggle(message.id)} aria-label={locale.AiChatDialogue.selectMessage} />
            }
            <Avatar class="lotus-ai-dialogue-avatar" size="small" src={meta.avatar} isText={!meta.avatar}>
                {meta.name ?? message.role}
            </Avatar>
            <div class="lotus-ai-dialogue-body">
                @if (meta.name) {
                    <div class="lotus-ai-dialogue-name">{meta.name}</div>
                }
                @if (message.editing) {
                    @if (messageEditRender) {
                        <>{messageEditRender(message)}</>
                    } @else {
                        <MessageEditor message={message} onSave={(content) => onEditSave(message, content)} onCancel={() => onEditToggle(message)} />
                    }
                } @else {
                    <div class={['lotus-ai-dialogue-content', bubble ? 'lotus-ai-dialogue-bubble' : ''].filter(Boolean).join(' ')}>
                        @for (const item of contentItems; index i) {
                            <ContentItemRenderer
                                item={item}
                                messageStatus={message.status}
                                onFileClick={onFileClick}
                                onImageClick={onImageClick}
                                onAnnotationClick={onAnnotationClick}
                                disabledFileItemClick={disabledFileItemClick}
                            />
                        }
                    </div>
                }
                @if (!message.editing) {
                    <div class="lotus-ai-dialogue-actions">
                        <button type="button" class="lotus-ai-dialogue-action" aria-label={locale.AiChatDialogue.copy} onClick={handleCopy}><IconCopy /></button>
                        @if (isUser) {
                            <button type="button" class="lotus-ai-dialogue-action" aria-label={locale.AiChatDialogue.edit} onClick={() => onEditToggle(message)}><IconEdit /></button>
                        }
                        @if (!isUser) {
                            <>
                                <button
                                    type="button"
                                    class={['lotus-ai-dialogue-action', message.like ? 'lotus-ai-dialogue-action-active' : ''].filter(Boolean).join(' ')}
                                    aria-label={locale.AiChatDialogue.like}
                                    onClick={() => onLike(message)}
                                ><IconLikeThumb /></button>
                                <button
                                    type="button"
                                    class={['lotus-ai-dialogue-action', message.dislike ? 'lotus-ai-dialogue-action-active' : ''].filter(Boolean).join(' ')}
                                    aria-label={locale.AiChatDialogue.dislike}
                                    onClick={() => onDislike(message)}
                                ><IconDislikeThumb /></button>
                                @if (showReset) {
                                    <button type="button" class="lotus-ai-dialogue-action" aria-label={locale.AiChatDialogue.regenerate} onClick={() => onReset(message)}><IconRefresh /></button>
                                }
                            </>
                        }
                        @if (showReference) {
                            <button type="button" class="lotus-ai-dialogue-action" aria-label={locale.AiChatDialogue.reference} onClick={() => onReference(message)}><IconShareStroked /></button>
                        }
                        <button type="button" class="lotus-ai-dialogue-action" aria-label={locale.AiChatDialogue.delete} onClick={() => onDelete(message)}><IconDelete /></button>
                    </div>
                }
            </div>
        </li>

        <style>
            .lotus-ai-dialogue-box {
                display: flex;
                gap: 8px;
                align-items: flex-start;
            }

            .lotus-ai-dialogue-box-right {
                flex-direction: row-reverse;
            }

            .lotus-ai-dialogue-body {
                display: flex;
                flex-direction: column;
                gap: 4px;
                max-width: 80%;
                min-width: 0;
            }

            .lotus-ai-dialogue-box-right .lotus-ai-dialogue-body {
                align-items: flex-end;
            }

            .lotus-ai-dialogue-name {
                font-size: 12px;
                color: var(--lotus-color-text-2);
            }

            .lotus-ai-dialogue-content {
                word-break: break-word;
                min-width: 0;
            }

            .lotus-ai-dialogue-bubble {
                background: var(--lotus-color-fill-1);
                border-radius: var(--lotus-border-radius-medium);
                padding: 8px 12px;
            }

            .lotus-ai-dialogue-box-right .lotus-ai-dialogue-bubble {
                background: var(--lotus-color-primary-light-default);
            }

            .lotus-ai-dialogue-actions {
                display: flex;
                gap: 4px;
            }

            .lotus-ai-dialogue-action {
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

            .lotus-ai-dialogue-action:hover {
                background: var(--lotus-color-fill-1);
                color: var(--lotus-color-text-0);
            }

            .lotus-ai-dialogue-action-active {
                color: var(--lotus-color-primary);
            }
        </style>
    </>
}
