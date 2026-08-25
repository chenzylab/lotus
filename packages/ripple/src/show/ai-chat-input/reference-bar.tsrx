import { referenceLabel, isImageReference, type AiInputReference } from '@lotus/foundation/show/ai-chat-input';
import { IconClose, IconFile } from '@lotus/icons';

export interface ReferenceBarProps {
    references: AiInputReference[];
    renderReference?: (reference: AiInputReference) => any;
    onReferenceDelete?: (reference: AiInputReference) => void;
    onReferenceClick?: (reference: AiInputReference) => void;
}

/** 引用条：展示在编辑区上方，每项可点击/删除。图片引用显示缩略图，其余显示文件图标+文本。 */
export function ReferenceBar(&{ references, renderReference, onReferenceDelete, onReferenceClick }: ReferenceBarProps) @{
    <>
        <div class="lotus-ai-input-reference-bar" role="list" aria-label="引用列表">
            @for (const reference of references; key reference.id) {
                @if (renderReference) {
                    <>{renderReference(reference)}</>
                } @else {
                    <div class="lotus-ai-input-reference-item" role="listitem" onClick={() => onReferenceClick?.(reference)}>
                        @if (isImageReference(reference)) {
                            <img class="lotus-ai-input-reference-thumb" src={reference.url} alt="" />
                        } @else {
                            <IconFile />
                        }
                        <span class="lotus-ai-input-reference-label">{referenceLabel(reference)}</span>
                        <button
                            type="button"
                            class="lotus-ai-input-reference-remove"
                            aria-label="删除引用"
                            onClick={(event: MouseEvent) => { event.stopPropagation(); onReferenceDelete?.(reference); }}
                        ><IconClose /></button>
                    </div>
                }
            }
        </div>

        <style>
            .lotus-ai-input-reference-bar {
                display: flex;
                flex-wrap: wrap;
                gap: 6px;
                margin-bottom: 8px;
            }

            .lotus-ai-input-reference-item {
                display: inline-flex;
                align-items: center;
                gap: 4px;
                background: var(--lotus-color-fill-0);
                border: 1px solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-small);
                padding: 2px 6px;
                font-size: 12px;
                color: var(--lotus-color-text-1);
                cursor: pointer;
                max-width: 200px;
            }

            .lotus-ai-input-reference-thumb {
                width: 16px;
                height: 16px;
                border-radius: 2px;
                object-fit: cover;
                flex-shrink: 0;
            }

            .lotus-ai-input-reference-label {
                overflow: hidden;
                text-overflow: ellipsis;
                white-space: nowrap;
            }

            .lotus-ai-input-reference-remove {
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

            .lotus-ai-input-reference-remove:hover {
                color: var(--lotus-color-text-0);
            }
        </style>
    </>
}
