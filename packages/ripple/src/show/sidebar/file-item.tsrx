import { track, effect, untrack } from 'ripple';
import { Editor, type Extension, type AnyExtension } from '@tiptap/core';
import StarterKit from '@tiptap/starter-kit';
import { TextStyleKit } from '@tiptap/extension-text-style';
import ImageExtension from '@tiptap/extension-image';
import TextAlign from '@tiptap/extension-text-align';
import { defaultMenuBarActiveState, type MenuBarActiveState, type ImageUploadNodeOptions } from '@lotus/foundation/show/sidebar';
import { createImageUploadNode } from './image-upload-node.js';
import {
    IconBold,
    IconItalic,
    IconStrikeThrough,
    IconCode,
    IconH1,
    IconH2,
    IconH3,
    IconList,
    IconOrderedList,
    IconQuote,
    IconAlignLeft,
    IconAlignCenter,
    IconAlignRight,
    IconUndo,
    IconRedo,
    IconLink,
    IconImage,
} from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export interface FileItemProps {
    content?: string;
    editable?: boolean;
    onContentChange?: (html: string) => void;
    extensions?: AnyExtension[];
    imgUploadProps?: ImageUploadNodeOptions;
    class?: string;
    style?: Record<string, any>;
}

function buildExtensions(imgUploadProps: ImageUploadNodeOptions | undefined, extraExtensions: AnyExtension[]): AnyExtension[] {
    return [
        TextStyleKit as unknown as AnyExtension,
        StarterKit.configure({
            link: { openOnClick: false, enableClickSelection: true },
        }) as unknown as AnyExtension,
        ImageExtension as unknown as AnyExtension,
        TextAlign.configure({ types: ['heading', 'paragraph'] }) as unknown as AnyExtension,
        createImageUploadNode(imgUploadProps) as unknown as AnyExtension,
        ...extraExtensions,
    ];
}

/**
 * Sidebar.FileItem：tiptap 富文本编辑器容器 + 完整 MenuBar 工具栏。默认
 * 扩展集顺序对齐 Semi 源码（TextStyleKit → StarterKit → Image →
 * TextAlign → ImageUploadNode，用户 `extensions` 拼接在末尾）；工具栏激活态
 * 通过 `editor.on('transaction', ...)` 订阅刷新（tiptap 无内置响应式绑定，
 * 这是 Adapter 层需要自行处理的框架桥接，与 Lottie 的 `AnimationItem`
 * 命令式实例管理是同一模式）。
 */
export function FileItem(&{
    content = '',
    editable = true,
    onContentChange,
    extensions = [],
    imgUploadProps,
    class: className,
    style,
}: FileItemProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    let &[containerEl] = track<HTMLDivElement | null>(null);
    let editor: Editor | null = null;
    let &[activeState] = track<MenuBarActiveState>(defaultMenuBarActiveState());
    let &[canUndo] = track<boolean>(false);
    let &[canRedo] = track<boolean>(false);

    function refreshActiveState() {
        if (!editor) return;
        activeState = {
            bold: editor.isActive('bold'),
            italic: editor.isActive('italic'),
            strike: editor.isActive('strike'),
            code: editor.isActive('code'),
            heading1: editor.isActive('heading', { level: 1 }),
            heading2: editor.isActive('heading', { level: 2 }),
            heading3: editor.isActive('heading', { level: 3 }),
            bulletList: editor.isActive('bulletList'),
            orderedList: editor.isActive('orderedList'),
            blockquote: editor.isActive('blockquote'),
            codeBlock: editor.isActive('codeBlock'),
            alignLeft: editor.isActive({ textAlign: 'left' }),
            alignCenter: editor.isActive({ textAlign: 'center' }),
            alignRight: editor.isActive({ textAlign: 'right' }),
        };
        canUndo = editor.can().undo();
        canRedo = editor.can().redo();
    }

    effect(() => {
        const container = containerEl;
        if (!container) return;
        const instance = new Editor({
            element: container,
            extensions: buildExtensions(imgUploadProps, extensions),
            content: untrack(() => content),
            editable: untrack(() => editable),
            onUpdate: ({ editor: e }) => {
                onContentChange?.(e.getHTML());
                refreshActiveState();
            },
            onTransaction: () => refreshActiveState(),
        });
        editor = instance;
        refreshActiveState();
        return () => {
            instance.destroy();
            editor = null;
        };
    });

    effect(() => {
        editor?.setEditable(editable);
    });

    <>
        <div class={['lotus-file-item', className ?? ''].filter(Boolean).join(' ')} style={style}>
            @if (editable) {
                <div class="lotus-file-item-menubar" role="toolbar">
                    <button type="button" disabled={!canUndo} onClick={() => editor?.chain().focus().undo().run()} aria-label={locale.RichTextEditor.undo}><IconUndo /></button>
                    <button type="button" disabled={!canRedo} onClick={() => editor?.chain().focus().redo().run()} aria-label={locale.RichTextEditor.redo}><IconRedo /></button>
                    <span class="lotus-file-item-menubar-divider" />
                    <button type="button" class={activeState.heading1 ? 'active' : ''} onClick={() => editor?.chain().focus().toggleHeading({ level: 1 }).run()} aria-label={locale.RichTextEditor.heading1}><IconH1 /></button>
                    <button type="button" class={activeState.heading2 ? 'active' : ''} onClick={() => editor?.chain().focus().toggleHeading({ level: 2 }).run()} aria-label={locale.RichTextEditor.heading2}><IconH2 /></button>
                    <button type="button" class={activeState.heading3 ? 'active' : ''} onClick={() => editor?.chain().focus().toggleHeading({ level: 3 }).run()} aria-label={locale.RichTextEditor.heading3}><IconH3 /></button>
                    <span class="lotus-file-item-menubar-divider" />
                    <button type="button" class={activeState.bulletList ? 'active' : ''} onClick={() => editor?.chain().focus().toggleBulletList().run()} aria-label={locale.RichTextEditor.bulletList}><IconList /></button>
                    <button type="button" class={activeState.orderedList ? 'active' : ''} onClick={() => editor?.chain().focus().toggleOrderedList().run()} aria-label={locale.RichTextEditor.orderedList}><IconOrderedList /></button>
                    <button type="button" class={activeState.blockquote ? 'active' : ''} onClick={() => editor?.chain().focus().toggleBlockquote().run()} aria-label={locale.RichTextEditor.blockquote}><IconQuote /></button>
                    <button type="button" class={activeState.codeBlock ? 'active' : ''} onClick={() => editor?.chain().focus().toggleCodeBlock().run()} aria-label={locale.RichTextEditor.codeBlock}><IconCode /></button>
                    <span class="lotus-file-item-menubar-divider" />
                    <button type="button" class={activeState.alignLeft ? 'active' : ''} onClick={() => editor?.chain().focus().setTextAlign('left').run()} aria-label={locale.RichTextEditor.alignLeft}><IconAlignLeft /></button>
                    <button type="button" class={activeState.alignCenter ? 'active' : ''} onClick={() => editor?.chain().focus().setTextAlign('center').run()} aria-label={locale.RichTextEditor.alignCenter}><IconAlignCenter /></button>
                    <button type="button" class={activeState.alignRight ? 'active' : ''} onClick={() => editor?.chain().focus().setTextAlign('right').run()} aria-label={locale.RichTextEditor.alignRight}><IconAlignRight /></button>
                    <span class="lotus-file-item-menubar-divider" />
                    <button type="button" class={activeState.bold ? 'active' : ''} onClick={() => editor?.chain().focus().toggleBold().run()} aria-label={locale.RichTextEditor.bold}><IconBold /></button>
                    <button type="button" class={activeState.italic ? 'active' : ''} onClick={() => editor?.chain().focus().toggleItalic().run()} aria-label={locale.RichTextEditor.italic}><IconItalic /></button>
                    <button type="button" class={activeState.strike ? 'active' : ''} onClick={() => editor?.chain().focus().toggleStrike().run()} aria-label={locale.RichTextEditor.strike}><IconStrikeThrough /></button>
                    <button type="button" class={activeState.code ? 'active' : ''} onClick={() => editor?.chain().focus().toggleCode().run()} aria-label={locale.RichTextEditor.inlineCode}><IconCode /></button>
                    <span class="lotus-file-item-menubar-divider" />
                    <button
                        type="button"
                        onClick={() => {
                            const url = window.prompt(locale.RichTextEditor.linkUrlPrompt);
                            if (url) editor?.chain().focus().setLink({ href: url }).run();
                        }}
                        aria-label={locale.RichTextEditor.insertLink}
                    ><IconLink /></button>
                    <button
                        type="button"
                        onClick={() => editor?.chain().focus().insertContent({ type: 'imageUpload' }).run()}
                        aria-label={locale.RichTextEditor.insertImage}
                    ><IconImage /></button>
                </div>
            }
            <div class="lotus-file-item-editor" ref={(node: HTMLDivElement | null) => { containerEl = node; }} />
        </div>

        <style>
            .lotus-file-item {
                display: flex;
                flex-direction: column;
                border: 1px solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-small);
                overflow: hidden;
            }

            .lotus-file-item-menubar {
                display: flex;
                flex-wrap: wrap;
                align-items: center;
                gap: 2px;
                padding: 4px;
                border-bottom: 1px solid var(--lotus-color-border);
                background: var(--lotus-color-fill-0);
            }

            .lotus-file-item-menubar button {
                display: flex;
                align-items: center;
                justify-content: center;
                width: 24px;
                height: 24px;
                border: none;
                background: transparent;
                border-radius: var(--lotus-border-radius-small);
                color: var(--lotus-color-text-1);
                cursor: pointer;
            }

            .lotus-file-item-menubar button:hover {
                background: var(--lotus-color-fill-1);
            }

            .lotus-file-item-menubar button.active {
                background: var(--lotus-color-fill-2);
                color: var(--lotus-color-primary);
            }

            .lotus-file-item-menubar button:disabled {
                opacity: 0.4;
                cursor: not-allowed;
            }

            .lotus-file-item-menubar-divider {
                width: 1px;
                height: 16px;
                background: var(--lotus-color-border);
                margin: 0 2px;
            }

            .lotus-file-item-editor {
                padding: 8px 12px;
                min-height: 120px;
                font-size: 14px;
                color: var(--lotus-color-text-0);
            }

            .lotus-file-item-editor :global(.tiptap) {
                outline: none;
            }

            .lotus-file-item-editor :global(.tiptap p) {
                margin: 0 0 8px;
            }

            .lotus-file-item-editor :global(.lotus-file-item-image-upload) {
                display: flex;
                align-items: center;
                justify-content: center;
                min-height: 80px;
                border: 1px dashed var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-small);
                cursor: pointer;
                color: var(--lotus-color-text-2);
                font-size: 13px;
            }

            .lotus-file-item-editor :global(.lotus-file-item-image-upload:hover) {
                border-color: var(--lotus-color-primary);
                color: var(--lotus-color-primary);
            }
        </style>
    </>
}
