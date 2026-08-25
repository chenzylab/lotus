import { Node, mergeAttributes } from '@tiptap/core';
import type { NodeViewRenderer } from '@tiptap/core';
import { getCustomSlotAttribute } from '@lotus/foundation/show/ai-chat-input';

/**
 * skillSlot：内联 atom 节点，展示为不可编辑的技能 chip（图标+label），可
 * 点击删除按钮整体移除。纯 DOM NodeView（对齐 Sidebar ImageUploadNode 已验证
 * 手法），不依赖 svelte-tiptap/react-tiptap 这类框架绑定包——lotus/Ripple
 * 生态目前没有等价社区包，纯 DOM NodeView 是唯一不引入额外依赖的路线。
 */
export const SkillSlot = Node.create({
    name: 'skillSlot',
    group: 'inline',
    inline: true,
    atom: true,
    selectable: true,

    addAttributes() {
        return {
            value: { default: '', parseHTML: (el) => el.getAttribute('data-value') },
            label: { default: '', parseHTML: (el) => el.getAttribute('data-label') },
            hasTemplate: { default: false, parseHTML: (el) => el.getAttribute('data-template') === 'true' },
            isCustomSlot: getCustomSlotAttribute(),
        };
    },

    parseHTML() {
        return [{ tag: 'skill-slot' }];
    },

    renderHTML({ HTMLAttributes, node }) {
        return [
            'skill-slot',
            mergeAttributes(HTMLAttributes, {
                'data-value': node.attrs.value,
                'data-label': node.attrs.label,
                'data-template': String(node.attrs.hasTemplate),
            }),
        ];
    },

    addNodeView(): NodeViewRenderer {
        return ({ node, editor, getPos }) => {
            const dom = document.createElement('span');
            dom.className = 'lotus-ai-input-skill-slot';
            dom.contentEditable = 'false';

            const label = document.createElement('span');
            label.className = 'lotus-ai-input-skill-slot-label';
            label.textContent = node.attrs.label || node.attrs.value || '';
            dom.appendChild(label);

            const removeBtn = document.createElement('button');
            removeBtn.type = 'button';
            removeBtn.className = 'lotus-ai-input-skill-slot-remove';
            removeBtn.textContent = '×';
            removeBtn.setAttribute('aria-label', '移除技能');
            removeBtn.addEventListener('click', (event) => {
                event.preventDefault();
                event.stopPropagation();
                const pos = typeof getPos === 'function' ? getPos() : undefined;
                if (pos === undefined) return;
                editor.chain().focus().deleteRange({ from: pos, to: pos + node.nodeSize }).run();
            });
            dom.appendChild(removeBtn);

            return { dom };
        };
    },
});
