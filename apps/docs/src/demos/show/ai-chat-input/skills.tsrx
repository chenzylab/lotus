import { track } from 'ripple';
import { AiChatInput, TypographyText } from '@lotus/ripple';

export function SkillsAiChatInputDemo() @{
    let &[skillLog] = track<string>('');

    <div style={{ maxWidth: '480px' }}>
        <AiChatInput
            placeholder="输入 / 触发技能..."
            skillHotKey="/"
            skills={[
                { value: 'translate', label: '翻译' },
                { value: 'summarize', label: '总结' },
            ]}
            onSkillChange={(skill) => { skillLog = `已选择技能：${skill.label}`; }}
        />
        <TypographyText type="secondary">{skillLog}</TypographyText>
    </div>
}
