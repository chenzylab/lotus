import { skillLabel, type AiInputSkill } from '@lotus/foundation/show/ai-chat-input';

export interface SkillPanelProps {
    skills: AiInputSkill[];
    renderSkillItem?: (args: { skill: AiInputSkill; onClick: () => void }) => any;
    onSkillClick: (skill: AiInputSkill) => void;
}

/** 技能选择面板：空输入时按 skillHotKey 触发，列表逐项渲染，点击选中技能。 */
export function SkillPanel(&{ skills, renderSkillItem, onSkillClick }: SkillPanelProps) @{
    <>
        <div class="lotus-ai-input-skill-panel" role="listbox" aria-label="技能列表">
            @for (const skill of skills; index i) {
                @if (renderSkillItem) {
                    <>{renderSkillItem({ skill, onClick: () => onSkillClick(skill) })}</>
                } @else {
                    <div class="lotus-ai-input-skill-item" role="option" onClick={() => onSkillClick(skill)}>
                        @if (skill.icon) {
                            <span class="lotus-ai-input-skill-item-icon">{skill.icon}</span>
                        }
                        <span class="lotus-ai-input-skill-item-label">{skillLabel(skill)}</span>
                    </div>
                }
            }
        </div>

        <style>
            .lotus-ai-input-skill-panel {
                min-width: 180px;
                max-height: 240px;
                overflow-y: auto;
            }

            .lotus-ai-input-skill-item {
                display: flex;
                align-items: center;
                gap: 8px;
                padding: 6px 10px;
                border-radius: var(--lotus-border-radius-small);
                cursor: pointer;
                font-size: 13px;
                color: var(--lotus-color-text-0);
            }

            .lotus-ai-input-skill-item:hover {
                background: var(--lotus-color-fill-0);
            }

            .lotus-ai-input-skill-item-icon {
                display: inline-flex;
                align-items: center;
                color: var(--lotus-color-text-2);
            }
        </style>
    </>
}
