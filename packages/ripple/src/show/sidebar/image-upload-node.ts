import { Node, mergeAttributes } from '@tiptap/core';
import type { NodeViewRenderer } from '@tiptap/core';
import type { ImageUploadNodeOptions } from '@lotus/foundation/show/sidebar';

/**
 * Semi 源码的 `ImageUploadNode` 用 `ReactNodeViewRenderer` 挂载一个 React
 * 组件（依赖 `@tiptap/react`）。lotus 没有对应的 React 运行时，改用 tiptap
 * core 原生支持的纯 DOM NodeView（`addNodeView` 直接返回 `{dom}`，不依赖
 * 任何框架绑定包）：点击/拖拽触发文件选择，用 FileReader 转 base64 dataURL
 * 直接插入图片节点——不复用 lotus 的 Upload 组件（其真实 XHR 上传流程需要
 * 后端 action 端点，这里的合理简化是本地读图不发网络请求）。
 */
export function createImageUploadNode(options: ImageUploadNodeOptions = {}) {
    return Node.create<ImageUploadNodeOptions>({
        name: 'imageUpload',
        group: 'block',
        draggable: true,
        selectable: true,
        atom: true,

        addOptions() {
            return {
                accept: 'image/*',
                maxSize: undefined,
                onChange: undefined,
                onSuccess: undefined,
                onError: undefined,
                ...options,
            };
        },

        parseHTML() {
            return [{ tag: 'div[data-type="image-upload"]' }];
        },

        renderHTML({ HTMLAttributes }) {
            return ['div', mergeAttributes({ 'data-type': 'image-upload' }, HTMLAttributes)];
        },

        addNodeView(): NodeViewRenderer {
            const nodeOptions = this.options;
            return ({ editor, getPos }) => {
                const dom = document.createElement('div');
                dom.className = 'lotus-file-item-image-upload';
                dom.tabIndex = 0;

                const input = document.createElement('input');
                input.type = 'file';
                input.accept = nodeOptions.accept ?? 'image/*';
                input.style.display = 'none';

                const hint = document.createElement('div');
                hint.className = 'lotus-file-item-image-upload-hint';
                hint.textContent = '点击或拖拽图片到此处上传';
                dom.appendChild(hint);
                dom.appendChild(input);

                function insertImage(src: string, name: string) {
                    const pos = typeof getPos === 'function' ? getPos() : undefined;
                    if (pos === undefined) return;
                    editor
                        .chain()
                        .focus()
                        .deleteRange({ from: pos, to: pos + 1 })
                        .insertContentAt(pos, { type: 'image', attrs: { src, alt: name, title: name } })
                        .run();
                }

                function handleFile(file: File) {
                    if (typeof nodeOptions.maxSize === 'number' && file.size > nodeOptions.maxSize) return;
                    nodeOptions.onChange?.(file);
                    const reader = new FileReader();
                    reader.onload = () => {
                        const src = String(reader.result);
                        nodeOptions.onSuccess?.(src, file);
                        insertImage(src, file.name);
                    };
                    reader.onerror = (error) => {
                        nodeOptions.onError?.(error, file);
                    };
                    reader.readAsDataURL(file);
                }

                dom.addEventListener('click', () => input.click());
                input.addEventListener('change', () => {
                    const file = input.files?.[0];
                    if (file) handleFile(file);
                    input.value = '';
                });
                dom.addEventListener('dragover', (event) => event.preventDefault());
                dom.addEventListener('drop', (event) => {
                    event.preventDefault();
                    const file = event.dataTransfer?.files?.[0];
                    if (file) handleFile(file);
                });

                return { dom };
            };
        },
    });
}
