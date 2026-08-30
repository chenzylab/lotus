import { track } from 'ripple';
import { AiChatDialogue, Button, Space, streamingResponseToMessage, type AiChatMessage } from '@lotus/ripple';

export function StreamingAiChatDialogueDemo() @{
    let &[chats] = track<AiChatMessage[]>(() => []);
    let streamState: any = null;

    function startStream() {
        const chunks = [
            { type: 'response.output_item.added', sequence_number: 0, output_index: 0, item: { type: 'message' } },
            { type: 'response.output_text.delta', sequence_number: 1, output_index: 0, content_index: 0, delta: '这是' },
        ];
        const result = streamingResponseToMessage(chunks, streamState);
        streamState = result?.nextState ?? null;
        if (result?.message) chats = [...chats, { ...result.message, id: 'stream-demo' } as AiChatMessage];
    }

    function appendDelta() {
        const chunks = [{ type: 'response.output_text.delta', sequence_number: 2, output_index: 0, content_index: 0, delta: '流式增量文本，逐步追加。' }];
        const result = streamingResponseToMessage(chunks, streamState);
        streamState = result?.nextState ?? null;
        if (result?.message) chats = chats.map((m) => (m.id === 'stream-demo' ? { ...result.message, id: 'stream-demo' } as AiChatMessage : m));
    }

    function completeStream() {
        const chunks = [{ type: 'response.completed', sequence_number: 3, response: { status: 'completed' } }];
        const result = streamingResponseToMessage(chunks, streamState);
        streamState = result?.nextState ?? null;
        if (result?.message) chats = chats.map((m) => (m.id === 'stream-demo' ? { ...result.message, id: 'stream-demo' } as AiChatMessage : m));
    }

    <>
        <div style={{ height: '240px', border: '1px solid var(--lotus-color-border)', borderRadius: '8px' }}>
            <AiChatDialogue chats={chats} onChatsChange={(next) => { chats = next; }} />
        </div>
        <Space style={{ marginTop: '8px' }}>
            <Button onClick={startStream}>模拟流式回复开始</Button>
            <Button onClick={appendDelta}>追加流式增量</Button>
            <Button onClick={completeStream}>标记流式完成</Button>
        </Space>
    </>
}
