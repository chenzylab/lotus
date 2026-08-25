import { formatFileSize, isReasoningItem, isToolCallItem, isMCPCallItem, isImageItem, isFileItem, isAnnotationItem, type AiContentItem, type AiMessageStatus } from '@lotus/foundation/show/ai-chat-dialogue';
import { MarkdownRender } from '../markdown-render/index.tsrx';
import { ReasoningBlock } from './reasoning-block.tsrx';
import { ToolCallBlock } from './tool-call-block.tsrx';
import { IconFile, IconDownload, IconLink } from '@lotus/icons';

export interface ContentItemRendererProps {
    item: AiContentItem;
    messageStatus?: AiMessageStatus;
    onFileClick?: (item: AiContentItem) => void;
    onImageClick?: (item: AiContentItem) => void;
    onAnnotationClick?: (item: AiContentItem) => void;
    disabledFileItemClick?: boolean;
}

/**
 * 单个 ContentItem 按类型分派渲染。文本走 MarkdownRender（自动获得代码块高亮，
 * 见 MarkdownRender 已有的 pre>code → CodeHighlight 转发，不需要额外扩展）；
 * reasoning/tool_call/mcp_call 委托给各自的专用块组件；图片/文件/引用注释
 * 就地渲染卡片。
 */
export function ContentItemRenderer(&{ item, messageStatus, onFileClick, onImageClick, onAnnotationClick, disabledFileItemClick = false }: ContentItemRendererProps) @{
    <>
        @if (isReasoningItem(item)) {
            <ReasoningBlock item={item} messageStatus={messageStatus} />
        } @else if (isToolCallItem(item) || isMCPCallItem(item)) {
            <ToolCallBlock item={item} />
        } @else if (isImageItem(item)) {
            <div class="lotus-ai-content-image" role="button" tabIndex={0} onClick={() => onImageClick?.(item)}>
                <img src={item.image_url} alt="" />
            </div>
        } @else if (isFileItem(item)) {
            <div
                class="lotus-ai-content-file"
                role="button"
                tabIndex={disabledFileItemClick ? -1 : 0}
                onClick={() => { if (!disabledFileItemClick) onFileClick?.(item); }}
            >
                <IconFile />
                <div class="lotus-ai-content-file-info">
                    <div class="lotus-ai-content-file-name">{item.file_name}</div>
                    <div class="lotus-ai-content-file-size">{formatFileSize(item.file_size)}</div>
                </div>
                <IconDownload />
            </div>
        } @else if (isAnnotationItem(item)) {
            <div class="lotus-ai-content-annotation" role="button" tabIndex={0} onClick={() => onAnnotationClick?.(item)}>
                <IconLink />
                <span>{item.title ?? item.url}</span>
            </div>
        } @else {
            <MarkdownRender raw={'text' in item ? item.text : ''} />
        }

        <style>
            .lotus-ai-content-image img {
                max-width: 100%;
                max-height: 300px;
                border-radius: var(--lotus-border-radius-medium);
                cursor: pointer;
            }

            .lotus-ai-content-file {
                display: flex;
                align-items: center;
                gap: 8px;
                padding: 8px;
                border: 1px solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-small);
                cursor: pointer;
                max-width: 280px;
            }

            .lotus-ai-content-file:hover {
                border-color: var(--lotus-color-primary);
            }

            .lotus-ai-content-file-info {
                flex: 1;
                min-width: 0;
            }

            .lotus-ai-content-file-name {
                font-size: 13px;
                color: var(--lotus-color-text-0);
                overflow: hidden;
                text-overflow: ellipsis;
                white-space: nowrap;
            }

            .lotus-ai-content-file-size {
                font-size: 12px;
                color: var(--lotus-color-text-2);
            }

            .lotus-ai-content-annotation {
                display: inline-flex;
                align-items: center;
                gap: 4px;
                font-size: 12px;
                color: var(--lotus-color-primary);
                cursor: pointer;
                margin-top: 4px;
            }

            .lotus-ai-content-annotation:hover {
                text-decoration: underline;
            }
        </style>
    </>
}
