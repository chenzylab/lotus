import type { AiInputSkill } from '@lotus/foundation/show/ai-chat-input';

export interface TemplatePanelProps {
    skill: AiInputSkill;
    renderTemplate: (skill: AiInputSkill, onTemplateClick: (content: string) => void) => any;
    onTemplateClick: (content: string) => void;
}

/**
 * 模版面板容器：内容完全由消费方通过 `renderTemplate` 提供（对齐 Semi 语义——
 * 模版本身是业务定制内容，lotus 不内置任何模版数据），本组件只负责承载浮层
 * 布局与把 `onTemplateClick` 回调转发给消费方渲染出的模版项。
 */
export function TemplatePanel(&{ skill, renderTemplate, onTemplateClick }: TemplatePanelProps) @{
    <>
        <div class="lotus-ai-input-template-panel">
            {renderTemplate(skill, onTemplateClick)}
        </div>

        <style>
            .lotus-ai-input-template-panel {
                min-width: 240px;
                max-height: 320px;
                overflow-y: auto;
            }
        </style>
    </>
}
