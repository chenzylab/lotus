import { Avatar } from '../avatar/index.tsrx';
import { IconCopy, IconLikeThumb, IconDislikeThumb, IconDelete } from '@lotus/icons';
import type { ChatMessage } from '@lotus/foundation/show/chat';

export interface ChatRoleMeta {
    name?: string;
    avatar?: string;
}

export type ChatRoleConfig = Partial<Record<'user' | 'assistant' | 'system', ChatRoleMeta>>;

export interface ChatMessageItemProps {
    message: ChatMessage;
    align: 'leftRight' | 'leftAlign';
    mode: 'bubble' | 'noBubble' | 'userBubble';
    roleConfig?: ChatRoleConfig;
    onCopy: (message: ChatMessage) => void;
    onLike: (message: ChatMessage) => void;
    onDislike: (message: ChatMessage) => void;
    onDelete: (message: ChatMessage) => void;
}

function roleMeta(role: string, roleConfig?: ChatRoleConfig): ChatRoleMeta {
    return (roleConfig as Record<string, ChatRoleMeta> | undefined)?.[role] ?? {};
}

function showBubble(mode: ChatMessageItemProps['mode'], role: string): boolean {
    if (mode === 'noBubble') return false;
    if (mode === 'userBubble') return role === 'user';
    return true;
}

export function ChatMessageItem(&{ message, align, mode, roleConfig, onCopy, onLike, onDislike, onDelete }: ChatMessageItemProps) @{
    const meta = roleMeta(message.role, roleConfig);
    const isUser = message.role === 'user';
    const onRight = align === 'leftRight' && isUser;
    const bubble = showBubble(mode, message.role);

    @if (message.role === 'divider') {
        <li class="lotus-chat-divider" role="separator" aria-label="上下文分隔线" />
    } @else {
        <li
            class={[
                'lotus-chat-message',
                onRight ? 'lotus-chat-message-right' : 'lotus-chat-message-left',
            ].filter(Boolean).join(' ')}
            data-role={message.role}
            data-message-id={message.id}
        >
            <Avatar class="lotus-chat-message-avatar" size="small" src={meta.avatar} isText={!meta.avatar}>
                {meta.name ?? message.role}
            </Avatar>
            <div class="lotus-chat-message-body">
                @if (meta.name) {
                    <div class="lotus-chat-message-name">{meta.name}</div>
                }
                <div class={['lotus-chat-message-content', bubble ? 'lotus-chat-message-bubble' : ''].filter(Boolean).join(' ')}>
                    @if (message.status === 'loading') {
                        <span class="lotus-chat-message-loading" aria-label="正在生成">···</span>
                    } @else {
                        <span class="lotus-chat-message-text">{message.content}</span>
                    }
                </div>
                @if (message.status !== 'loading') {
                    <div class="lotus-chat-message-actions">
                        <button type="button" class="lotus-chat-message-action" aria-label="复制" onClick={() => onCopy(message)}>
                            <IconCopy />
                        </button>
                        @if (!isUser) {
                            <>
                                <button
                                    type="button"
                                    class={['lotus-chat-message-action', message.like ? 'lotus-chat-message-action-active' : ''].filter(Boolean).join(' ')}
                                    aria-label="点赞"
                                    aria-pressed={!!message.like}
                                    onClick={() => onLike(message)}
                                >
                                    <IconLikeThumb />
                                </button>
                                <button
                                    type="button"
                                    class={['lotus-chat-message-action', message.dislike ? 'lotus-chat-message-action-active' : ''].filter(Boolean).join(' ')}
                                    aria-label="点踩"
                                    aria-pressed={!!message.dislike}
                                    onClick={() => onDislike(message)}
                                >
                                    <IconDislikeThumb />
                                </button>
                            </>
                        }
                        <button type="button" class="lotus-chat-message-action" aria-label="删除" onClick={() => onDelete(message)}>
                            <IconDelete />
                        </button>
                    </div>
                }
            </div>
        </li>
    }
}
