import { track } from 'ripple';
import { getAttachmentType, getContentType, isImageType, type AiInputAttachment } from '@lotus/foundation/show/ai-chat-input';
import { IconClose, IconFile, IconLoading } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export interface AttachmentListProps {
    attachments: AiInputAttachment[];
    onRemove: (attachment: AiInputAttachment) => void;
}

/**
 * 附件列表：展示在编辑区上方（引用条下方）。附件数据结构继承自 Upload 自身
 * 的 FileItem（`uid/name/status/url/fileInstance`），由渲染层把 `Upload`
 * 的 `onChange(fileList)` 回调结果映射成 `AiInputAttachment[]`——本组件只负责
 * 展示与删除，真实 XHR 上传流程完全交给 Upload 组件处理。
 */
export function AttachmentList(&{ attachments, onRemove }: AttachmentListProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    <>
        <div class="lotus-ai-input-attachment-list" role="list" aria-label={locale.AiChatInput.attachmentList}>
            @for (const attachment of attachments; key attachment.uid) {
                <div class="lotus-ai-input-attachment-item" role="listitem">
                    @if (isImageType(attachment)) {
                        <img class="lotus-ai-input-attachment-thumb" src={attachment.url} alt="" />
                    } @else {
                        <span class="lotus-ai-input-attachment-icon"><IconFile /></span>
                    }
                    <div class="lotus-ai-input-attachment-info">
                        <div class="lotus-ai-input-attachment-name">{attachment.name}</div>
                        <div class="lotus-ai-input-attachment-type">{getContentType(getAttachmentType(attachment))}</div>
                    </div>
                    @if (attachment.status === 'uploading') {
                        <span class="lotus-ai-input-attachment-loading"><IconLoading /></span>
                    }
                    <button
                        type="button"
                        class="lotus-ai-input-attachment-remove"
                        aria-label={locale.AiChatInput.removeAttachment}
                        onClick={() => onRemove(attachment)}
                    ><IconClose /></button>
                </div>
            }
        </div>

        <style>
            .lotus-ai-input-attachment-list {
                display: flex;
                flex-wrap: wrap;
                gap: 8px;
                margin-bottom: 8px;
            }

            .lotus-ai-input-attachment-item {
                display: flex;
                align-items: center;
                gap: 6px;
                border: 1px solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-small);
                padding: 4px 8px;
                max-width: 220px;
            }

            .lotus-ai-input-attachment-thumb {
                width: 24px;
                height: 24px;
                border-radius: 2px;
                object-fit: cover;
                flex-shrink: 0;
            }

            .lotus-ai-input-attachment-icon {
                display: inline-flex;
                flex-shrink: 0;
                color: var(--lotus-color-text-2);
            }

            .lotus-ai-input-attachment-info {
                flex: 1;
                min-width: 0;
            }

            .lotus-ai-input-attachment-name {
                font-size: 12px;
                color: var(--lotus-color-text-0);
                overflow: hidden;
                text-overflow: ellipsis;
                white-space: nowrap;
            }

            .lotus-ai-input-attachment-type {
                font-size: 11px;
                color: var(--lotus-color-text-3);
            }

            .lotus-ai-input-attachment-loading {
                display: inline-flex;
                color: var(--lotus-color-text-2);
                animation: lotus-ai-input-attachment-spin 1s linear infinite;
            }

            @keyframes lotus-ai-input-attachment-spin {
                from { transform: rotate(0deg); }
                to { transform: rotate(360deg); }
            }

            .lotus-ai-input-attachment-remove {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                border: none;
                background: transparent;
                color: var(--lotus-color-text-2);
                cursor: pointer;
                flex-shrink: 0;
                padding: 0;
            }

            .lotus-ai-input-attachment-remove:hover {
                color: var(--lotus-color-text-0);
            }
        </style>
    </>
}
