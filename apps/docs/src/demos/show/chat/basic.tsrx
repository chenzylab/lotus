import { track } from 'ripple';
import { Chat, type ChatMessage } from '@lotus/ripple';

export function BasicChatDemo() @{
    let &[chats] = track<ChatMessage[]>(() => [
        { id: 'demo-1', role: 'assistant', content: '你好，我可以帮你做什么？', status: 'complete' } as ChatMessage,
        { id: 'demo-2', role: 'user', content: '介绍一下 lotus 组件库', status: 'complete' } as ChatMessage,
    ]);

    <div style={{ width: '480px', height: '420px', border: '1px solid var(--lotus-color-border)', borderRadius: 'var(--lotus-border-radius-medium)' }}>
        <Chat
            chats={chats}
            roleConfig={{
                user: { name: '我' },
                assistant: { name: 'lotus 助手' },
            }}
            hints={['介绍一下组件库', '如何开始使用']}
            onChatsChange={(next) => { chats = next; }}
        />
    </div>
}
