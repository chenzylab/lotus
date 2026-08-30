import { track } from 'ripple';
import { AiChatDialogue, type AiChatMessage } from '@lotus/ripple';

export function BasicAiChatDialogueDemo() @{
    let &[chats] = track<AiChatMessage[]>(() => [
        { id: 'msg-1', role: 'user', content: '帮我查一下北京今天的天气' },
        {
            id: 'msg-2',
            role: 'assistant',
            status: 'completed',
            content: [
                { type: 'reasoning', summary: ['用户想查询天气，需要调用天气工具获取北京的实时数据。'] },
                { type: 'tool_call', call_id: 'call-1', name: 'get_weather', arguments: '{"city":"北京"}', status: 'completed', output: '{"temp":24,"condition":"晴"}' },
                { type: 'output_text', text: '北京今天 **24°C**，晴朗，适合出行。' },
            ],
        },
    ] as AiChatMessage[]);

    <div style={{ height: '320px', border: '1px solid var(--lotus-color-border)', borderRadius: '8px' }}>
        <AiChatDialogue
            chats={chats}
            roleConfig={{ user: { name: '我' }, assistant: { name: 'Lotus AI' } }}
            hints={['介绍一下 lotus 组件库', '帮我写一段 TypeScript 代码']}
            onChatsChange={(next) => { chats = next; }}
        />
    </div>
}
