import { track, untrack } from 'ripple';
import { extractPlainText, type AiChatMessage } from '@lotus/foundation/show/ai-chat-dialogue';
import { TextArea } from '../../input/text-area/index.tsrx';
import { Button } from '../../basic/button/index.tsrx';

export interface MessageEditorProps {
    message: AiChatMessage;
    onSave: (content: string) => void;
    onCancel: () => void;
}

/**
 * 消息编辑态的默认 UI：TextArea + 保存/取消。`messageEditRender` 传入时由
 * 调用方完全接管这块渲染（用于对接 AIChatInput 这类富编辑器），本组件只是
 * 未传时的默认回退实现。
 */
export function MessageEditor(&{ message, onSave, onCancel }: MessageEditorProps) @{
    let &[draft] = track<string>(() => extractPlainText(message.content));

    function handleSave() {
        onSave(untrack(() => draft));
    }

    <>
        <div class="lotus-ai-message-editor">
            <TextArea value={draft} autosize={true} onChange={(value: string) => { draft = value; }} />
            <div class="lotus-ai-message-editor-actions">
                <Button theme="light" size="small" onClick={onCancel}>取消</Button>
                <Button theme="solid" size="small" onClick={handleSave}>保存</Button>
            </div>
        </div>

        <style>
            .lotus-ai-message-editor {
                display: flex;
                flex-direction: column;
                gap: 8px;
            }

            .lotus-ai-message-editor-actions {
                display: flex;
                justify-content: flex-end;
                gap: 8px;
            }
        </style>
    </>
}
