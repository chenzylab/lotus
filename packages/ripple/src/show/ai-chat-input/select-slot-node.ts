import { Node, mergeAttributes } from '@tiptap/core';
import type { NodeViewRenderer } from '@tiptap/core';
import { getCustomSlotAttribute } from '@lotus/foundation/show/ai-chat-input';

/**
 * selectSlot：内联 atom 节点，渲染为原生 `<select>` 下拉（模版填空场景，如
 * "帮我把这段翻译成 [语言]"里的方括号部分）。纯 DOM NodeView，选中值变化时
 * 直接更新节点属性（`editor.commands.updateAttributes`），不需要额外状态管理。
 */
export const SelectSlot = Node.create({
    name: 'selectSlot',
    group: 'inline',
    inline: true,
    atom: true,
    selectable: true,

    addAttributes() {
        return {
            options: { default: '[]' },
            value: { default: '' },
            isCustomSlot: getCustomSlotAttribute(),
        };
    },

    parseHTML() {
        return [{ tag: 'select-slot' }];
    },

    renderHTML({ HTMLAttributes, node }) {
        return ['select-slot', mergeAttributes(HTMLAttributes, { options: node.attrs.options, value: node.attrs.value })];
    },

    addNodeView(): NodeViewRenderer {
        return ({ node, editor, getPos }) => {
            const dom = document.createElement('span');
            dom.className = 'lotus-ai-input-select-slot';
            dom.contentEditable = 'false';

            const select = document.createElement('select');
            select.className = 'lotus-ai-input-select-slot-native';

            let options: string[] = [];
            try {
                options = JSON.parse(node.attrs.options ?? '[]');
            } catch {
                options = [];
            }

            for (const option of options) {
                const optionEl = document.createElement('option');
                optionEl.value = option;
                optionEl.textContent = option;
                select.appendChild(optionEl);
            }
            select.value = node.attrs.value ?? '';

            select.addEventListener('change', () => {
                const pos = typeof getPos === 'function' ? getPos() : undefined;
                if (pos === undefined) return;
                editor.chain().command(({ tr }) => {
                    tr.setNodeAttribute(pos, 'value', select.value);
                    return true;
                }).run();
            });
            select.addEventListener('mousedown', (event) => event.stopPropagation());

            dom.appendChild(select);
            return { dom };
        };
    },
});
