import { track } from 'ripple';
import { AiChatInput, TypographyText } from '@lotus/ripple';

export function BasicAiChatInputDemo() @{
    let &[sentLog] = track<string>('');

    <div style={{ maxWidth: '480px' }}>
        <AiChatInput
            placeholder="输入消息，按 Enter 发送..."
            suggestions={['介绍一下 lotus 组件库', '帮我写一段 TypeScript 代码']}
            onMessageSend={(message) => {
                const text = message.inputContents
                    ?.map((c) => (c.type === 'text' ? String(c.text ?? '') : ''))
                    .join('') ?? '';
                sentLog = `已发送：${text}`;
            }}
        />
        <TypographyText type="secondary">{sentLog}</TypographyText>
    </div>
}
