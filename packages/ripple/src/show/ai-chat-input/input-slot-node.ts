import { Node, mergeAttributes } from '@tiptap/core';
import type { NodeViewRenderer } from '@tiptap/core';
import { getCustomSlotAttribute } from '@lotus/foundation/show/ai-chat-input';

/**
 * inputSlot：内联可编辑节点（非 atom），渲染为模版填空的可编辑空格（如
 * "帮我写一篇关于 [主题] 的文章"里的方括号部分）。用 tiptap 的
 * `{dom, contentDOM}` 双返回值 NodeView（tiptap 原生支持，非 Ripple/lotus
 * 自建机制）：`contentDOM` 交给 tiptap 自己管理内部可编辑文本的同步，
 * 外层 `dom` 只负责视觉包装（placeholder 态的虚化样式）。
 */
export const InputSlot = Node.create({
    name: 'inputSlot',
    group: 'inline',
    inline: true,
    content: 'text*',
    selectable: false,

    addAttributes() {
        return {
            placeholder: { default: '' },
            isCustomSlot: getCustomSlotAttribute(),
        };
    },

    parseHTML() {
        return [{ tag: 'input-slot' }];
    },

    renderHTML({ HTMLAttributes, node }) {
        return ['input-slot', mergeAttributes(HTMLAttributes, { placeholder: node.attrs.placeholder }), 0];
    },

    addNodeView(): NodeViewRenderer {
        return ({ node }) => {
            const dom = document.createElement('span');
            dom.className = 'lotus-ai-input-input-slot';

            const contentDOM = document.createElement('span');
            contentDOM.className = 'lotus-ai-input-input-slot-content';
            if (node.attrs.placeholder) contentDOM.setAttribute('data-placeholder', node.attrs.placeholder);
            dom.appendChild(contentDOM);

            return { dom, contentDOM };
        };
    },
});
