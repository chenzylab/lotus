import { track, effect, untrack } from 'ripple';
import { Editor, type Extension, type AnyExtension, type JSONContent } from '@tiptap/core';
import DocumentExtension from '@tiptap/extension-document';
import ParagraphExtension from '@tiptap/extension-paragraph';
import TextExtension from '@tiptap/extension-text';
import HardBreakExtension from '@tiptap/extension-hard-break';
import { isSendHotKey, shouldOpenSkillPanel, type AiInputSendHotKey } from '@lotus/foundation/show/ai-chat-input';
import { SkillSlot } from './skill-slot-node.js';
import { SelectSlot } from './select-slot-node.js';
import { InputSlot } from './input-slot-node.js';

export interface AiInputEditorProps {
    placeholder?: string;
    sendHotKey?: AiInputSendHotKey;
    skillHotKey?: string;
    skillCount?: number;
    extensions?: AnyExtension[];
    onContentChange?: (json: JSONContent, html: string, text: string) => void;
    onSend?: () => void;
    onOpenSkillPanel?: () => void;
    onFocus?: () => void;
    onBlur?: () => void;
    onPaste?: (event: ClipboardEvent) => void;
    getEditorApi?: (editor: Editor) => void;
    class?: string;
    style?: Record<string, any>;
}

function buildExtensions(extraExtensions: AnyExtension[]): AnyExtension[] {
    return [
        DocumentExtension as unknown as AnyExtension,
        ParagraphExtension as unknown as AnyExtension,
        TextExtension as unknown as AnyExtension,
        HardBreakExtension.configure({ keepMarks: false }) as unknown as AnyExtension,
        SkillSlot as unknown as AnyExtension,
        SelectSlot as unknown as AnyExtension,
        InputSlot as unknown as AnyExtension,
        ...extraExtensions,
    ];
}

/**
 * AiChatInput 的极简 tiptap 编辑器容器：`Document+Paragraph+Text+HardBreak`
 * 最小文档模型（不是 StarterKit——AiChatInput 不需要标题/列表/引用等通用富
 * 文本能力，只需要纯文本+三个自定义 slot），对齐 chenzy.design/Semi 的扩展
 * 集选型。编辑器实例通过 `getEditorApi` 回调交出（对齐 Cropper/Sidebar 已验证
 * 的命令式 API 模式）。
 */
export function AiInputEditor(&{
    placeholder,
    sendHotKey = 'enter',
    skillHotKey,
    skillCount = 0,
    extensions = [],
    onContentChange,
    onSend,
    onOpenSkillPanel,
    onFocus,
    onBlur,
    onPaste,
    getEditorApi,
    class: className,
    style,
}: AiInputEditorProps) @{
    let containerEl: HTMLDivElement | null = null;
    let editor: Editor | null = null;
    let &[isEmpty] = track<boolean>(true);

    effect(() => {
        const container = containerEl;
        if (!container) return;
        const instance = new Editor({
            element: container,
            extensions: buildExtensions(extensions),
            content: '',
            editorProps: {
                attributes: {
                    class: 'lotus-ai-input-editor-content',
                    ...(placeholder ? { 'data-placeholder': placeholder } : {}),
                },
                handleKeyDown: (view, event) => {
                    if (isSendHotKey(event.key, event.shiftKey, sendHotKey)) {
                        event.preventDefault();
                        onSend?.();
                        return true;
                    }
                    if (skillHotKey && event.key === skillHotKey) {
                        const empty = view.state.selection.empty && view.state.doc.textContent.length === 0;
                        if (shouldOpenSkillPanel({ key: event.key, skillHotKey, isEmpty: empty, skillCount })) {
                            event.preventDefault();
                            onOpenSkillPanel?.();
                            return true;
                        }
                    }
                    return false;
                },
                handlePaste: (_view, event) => {
                    onPaste?.(event);
                    return false;
                },
            },
            onUpdate: ({ editor: e }) => {
                isEmpty = e.isEmpty;
                onContentChange?.(e.getJSON(), e.getHTML(), e.getText());
            },
            onFocus: () => onFocus?.(),
            onBlur: () => onBlur?.(),
        });
        editor = instance;
        isEmpty = instance.isEmpty;
        getEditorApi?.(instance);
        return () => {
            instance.destroy();
            editor = null;
        };
    });

    <>
        <div
            class={['lotus-ai-input-editor', isEmpty ? 'lotus-ai-input-editor-empty' : '', className ?? ''].filter(Boolean).join(' ')}
            style={style}
            ref={(node: HTMLDivElement | null) => { containerEl = node; }}
        />

        <style>
            .lotus-ai-input-editor {
                min-height: 24px;
            }

            .lotus-ai-input-editor :global(.lotus-ai-input-editor-content) {
                outline: none;
            }

            .lotus-ai-input-editor :global(.lotus-ai-input-editor-content p) {
                margin: 0;
            }

            .lotus-ai-input-editor-empty :global(.lotus-ai-input-editor-content p:first-child::before) {
                content: attr(data-placeholder);
                color: var(--lotus-color-text-3);
                pointer-events: none;
                float: left;
                height: 0;
            }

            .lotus-ai-input-editor :global(.lotus-ai-input-skill-slot) {
                display: inline-flex;
                align-items: center;
                gap: 4px;
                background: var(--lotus-color-fill-1);
                border-radius: var(--lotus-border-radius-full);
                padding: 0 6px 0 8px;
                margin: 0 2px;
                font-size: 12px;
                color: var(--lotus-color-text-1);
                vertical-align: middle;
            }

            .lotus-ai-input-editor :global(.lotus-ai-input-skill-slot-remove) {
                border: none;
                background: transparent;
                color: var(--lotus-color-text-2);
                cursor: pointer;
                font-size: 14px;
                line-height: 1;
                padding: 0;
            }

            .lotus-ai-input-editor :global(.lotus-ai-input-select-slot-native) {
                border: 1px solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-small);
                font-size: 12px;
                padding: 0 4px;
                margin: 0 2px;
            }

            .lotus-ai-input-editor :global(.lotus-ai-input-input-slot) {
                display: inline-block;
                border-bottom: 1px dashed var(--lotus-color-border);
                min-width: 40px;
                padding: 0 2px;
            }

            .lotus-ai-input-editor :global(.lotus-ai-input-input-slot-content:empty::before) {
                content: attr(data-placeholder);
                color: var(--lotus-color-text-3);
            }
        </style>
    </>
}
